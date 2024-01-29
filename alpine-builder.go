package main

import (
    "bufio"
    "fmt"
    "os"
    "os/exec"
    "strings"

    "github.com/AlecAivazis/survey/v2"
)

var setupChoices = []string{
    "System Update",
    "Setup X Window System",
    "Install XFCE",
    "Install GNOME",
    "Install Display Manager (LightDM)",
    "Enable D-Bus",
    "Network Management",
    "Install ALSA",
    "Install PulseAudio",
    "Enable Display Manager (LightDM)",
    "Install Intel GPU Drivers",
    "Install AMD GPU Drivers",
    "Install Nvidia GPU Drivers",
    "Configure Xorg",
    "User Configuration",
    "Install Additional Software (Firefox)",
    "Reboot System",
    "Install Packages from programs.conf",
}

func executeCommand(command string, args ...string) {
    cmd := exec.Command(command, args...)
    err := cmd.Run()
    if err != nil {
        fmt.Printf("Failed to execute %s: %s\n", command, err)
    }
}

func configureUser() {
    file, err := os.Open("user.conf")
    if err != nil {
        fmt.Println("Error opening user.conf:", err)
        return
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        line := scanner.Text()
        parts := strings.Split(line, ":")
        if len(parts) == 2 {
            user := parts[0]
            groups := strings.Split(parts[1], ",")
            for _, group := range groups {
                executeCommand("adduser", user, group)
            }
        }
    }

    if err := scanner.Err(); err != nil {
        fmt.Println("Error reading user.conf:", err)
    }
}

func installPackagesFromConfig() {
    file, err := os.Open("programs.conf")
    if err != nil {
        fmt.Println("Error opening programs.conf:", err)
        return
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        packageName := scanner.Text()
        if packageName != "" {
            fmt.Printf("Installing package: %s\n", packageName)
            executeCommand("apk", "add", packageName)
        }
    }

    if err := scanner.Err(); err != nil {
        fmt.Println("Error reading programs.conf:", err)
    }
}

func executeSelectedChoices(selectedChoices []string) {
    for _, choice := range selectedChoices {
        fmt.Printf("Executing: %s\n", choice)
        switch choice {
        case "System Update":
            executeCommand("apk", "update")
            executeCommand("apk", "upgrade")
        case "Setup X Window System":
            executeCommand("apk", "add", "xorg-server")
        case "Install XFCE":
            executeCommand("apk", "add", "xfce4", "xfce4-terminal", "lightdm-gtk-greeter")
        case "Install GNOME":
            executeCommand("apk", "add", "gnome")
        case "Install Display Manager (LightDM)":
            executeCommand("apk", "add", "lightdm")
        case "Enable D-Bus":
            executeCommand("apk", "add", "dbus")
            executeCommand("rc-update", "add", "dbus")
            executeCommand("service", "dbus", "start")
        case "Network Management":
            executeCommand("apk", "add", "networkmanager")
            executeCommand("rc-update", "add", "networkmanager")
            executeCommand("service", "networkmanager", "start")
        case "Install ALSA":
            executeCommand("apk", "add", "alsa-utils")
        case "Install PulseAudio":
            executeCommand("apk", "add", "pulseaudio", "pulseaudio-alsa")
        case "Enable Display Manager (LightDM)":
            executeCommand("rc-update", "add", "lightdm")
            executeCommand("service", "lightdm", "start")
        case "Install Intel GPU Drivers":
            executeCommand("apk", "add", "xf86-video-intel")
        case "Install AMD GPU Drivers":
            executeCommand("apk", "add", "xf86-video-amdgpu")
        case "Install Nvidia GPU Drivers":
            executeCommand("apk", "add", "xf86-video-nouveau")
        case "Configure Xorg":
            executeCommand("Xorg", "-configure")
        case "User Configuration":
            configureUser()
        case "Install Additional Software (Firefox)":
            executeCommand("apk", "add", "firefox")
        case "Reboot System":
            executeCommand("reboot")
        case "Install Packages from programs.conf":
            installPackagesFromConfig()
        }
    }
}

func mainMenu() {
    var selectedChoices []string
    prompt := &survey.MultiSelect{
        Message: "Select Setup Steps:",
        Options: setupChoices,
    }
    survey.AskOne(prompt, &selectedChoices, nil)

    executeSelectedChoices(selectedChoices)
}

func main() {
    mainMenu()
}
