package main

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/hex"
	"flag"
	"fmt"
	"net/http"
	"os"
	"regexp"
	"sort"
	"strings"
	"text/template"

	"github.com/BurntSushi/toml"
)

type Config struct {
	Files       FilesConfig              `toml:"files"`
	RuffRelease RuffReleaseConfig        `toml:"ruff_release"`
	Platforms   map[string]PlatformEntry `toml:"platforms"`
}

type FilesConfig struct {
	VersionFile  string `toml:"version_file"`
	PlatformFile string `toml:"platform_file"`
}

type RuffReleaseConfig struct {
	BaseURL string `toml:"base_url"`
	File    string `toml:"file"`
	Hash    string `toml:"hash"`
}

type PlatformEntry struct {
	Arch   string `toml:"arch"`
	OS     string `toml:"os"`
	Vender string `toml:"vender"`
	Ext    string `toml:"ext"`
}

// contains checks if a string slice contains a specific string.
func contains(importedVersions []string, version string) bool {
	for _, item := range importedVersions {
		if item == version {
			return true
		}
	}
	return false
}

func sha256ToSRI(hexString string) (string, error) {
	hashBytes, err := hex.DecodeString(hexString)
	if err != nil {
		return "", fmt.Errorf("invalid hex string: %w", err)
	}
	base64Hash := base64.StdEncoding.EncodeToString(hashBytes)
	return "sha256-" + base64Hash, nil
}

func extrantOldVeirsions(path string) ([]string, error) {
	// Regular expression to match semantic versioning in the format ' "1.2.3" : {''
	pattern := `^\s*"([0-9]+\.[0-9]+\.[0-9]+(?:-[\w\.\-]+)?(?:\+[\w\.\-]+)?)"\s*:\s*\{`

	re := regexp.MustCompile(pattern)

	var lines []string

	file, err := os.Open(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "ファイルを開けません: %v\n", err)
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if re.MatchString(line) {
			// Extract the version string
			matches := re.FindStringSubmatch(line)
			if len(matches) > 1 {
				lines = append(lines, matches[1])
				fmt.Printf("Found version: %s\n", matches[1])
			}
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "読み込み中にエラー: %v\n", err)
		return nil, err
	}

	return lines, nil
}

func fetchRuffRelease(version string, config Config) ( map[string]string, error) {
	baseUrl := config.RuffRelease.BaseURL
	fileName := config.RuffRelease.File
	fileName = strings.ReplaceAll(fileName, "{", "{{.")
	fileName = strings.ReplaceAll(fileName, "}", "}}")

	urlTemplate := fmt.Sprintf("%s%s.%s", baseUrl, fileName, config.RuffRelease.Hash)
	integrities := make(map[string]string)

	for key, value := range config.Platforms {

		data := map[string]string{
			"arch": value.Arch,
			"vender": value.Vender,
			"os":   value.OS,
			"ext":  value.Ext,
			"version": version,
		}

		var buf bytes.Buffer
		err := template.Must(template.New("example").Parse(urlTemplate)).Execute(&buf, data)
		if err != nil {
			panic(err)
		}

		url := buf.String()
		fmt.Println("Result as string:", url)

		resp, err := http.Get(url)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch url: %w", err)
		}
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			return nil, fmt.Errorf("bad response status: %s", resp.Status)
		}

		var lines []string
		scanner := bufio.NewScanner(resp.Body)
		for scanner.Scan() {
			lines = append(lines, scanner.Text())
		}
		if err := scanner.Err(); err != nil {
			return nil, fmt.Errorf("reading error: %w", err)
		}

		parts := strings.Split(lines[0], " ")
		if len(parts) > 0 {
			integrity, err := sha256ToSRI(parts[0])
			if err != nil {
				return nil, fmt.Errorf("failed to convert to SRI: %w", err)
			}
			integrities[key] = integrity
		}
	}

	return integrities, nil
}

func updateVersionFile(path string, version string, integrities map[string]string) error {
	var lines []string

	input, err := os.Open(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "ファイルを開けません: %v\n", err)
		return err
	}
	defer input.Close()

	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "読み込み中にエラー: %v\n", err)
		return err
	}

	file, err := os.OpenFile(path, os.O_RDWR, 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open file: %v\n", err)
		return err
	}
	defer file.Close()

	file.Truncate(0) // Clear the file
	file.Seek(0, 0) // Move the cursor to the beginning
	for _, line := range lines {
		if strings.HasPrefix(line, "RUFF_VERSIONS") {
			fmt.Println(line)
			if _, err := file.WriteString(line + "\n"); err != nil {
				fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
				return err
			}
			line = fmt.Sprintf("    \"%s\": {", version)
			fmt.Println(line)
			if _, err := file.WriteString(line + "\n"); err != nil {
				fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
				return err
			}

			keys := make([]string, 0, len(integrities))
			for k := range integrities {
				keys = append(keys, k)
			}
			sort.Strings(keys)

			for _, k := range keys {
				line = fmt.Sprintf("        \"%s\": \"%s\",", k, integrities[k])
				fmt.Println(line)
				if _, err := file.WriteString(line + "\n"); err != nil {
					fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
					return err
				}
			}

			line = fmt.Sprintf("    },")
			fmt.Println(line)
			if _, err := file.WriteString(line + "\n"); err != nil {
				fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
				return err
			}
		} else if strings.HasPrefix(line, "RUFF_LAST_VERSIONS") {
			line = fmt.Sprintf("RUFF_LAST_VERSIONS = \"%s\"", version)
			fmt.Println(line)
			if _, err := file.WriteString(line + "\n"); err != nil {
				fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
				return err
			}
		} else {
			fmt.Println(line)
			if _, err := file.WriteString(line + "\n"); err != nil {
				fmt.Fprintf(os.Stderr, "Error writing to file: %v\n", err)
				return err
			}
		}
	}

	return nil
}

func checkError(err error) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func main() {
	// Define the named flag --config
	configPath := flag.String("config", "config.toml", "Path to configuration file")

	// Parse the named flags
	flag.Parse()

	// Check for the required positional argument: version
	args := flag.Args()
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "Error: missing required positional argument 'version'")
		fmt.Fprintf(os.Stderr, "Usage: %s --config <file> <version>\n", os.Args[0])
		os.Exit(1)
	}
	version := args[0]

	var config Config
	if _, err := toml.DecodeFile(*configPath, &config); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read config file: %v\n", err)
		os.Exit(1)
	}

	// Output the values
	fmt.Printf("Config file: %v\n", config)
	fmt.Printf("Version: %s\n", version)

	oldVersions, _ := extrantOldVeirsions(config.Files.VersionFile)

	if contains(oldVersions, version) {
		fmt.Printf("Version %s is already imported.\n", version)
		os.Exit(0)
	}

	integrities, err := fetchRuffRelease(version, config)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to fetch Ruff release: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Fetched integrities: %v\n", integrities)

	updateVersionFile(config.Files.VersionFile, version, integrities)
}
