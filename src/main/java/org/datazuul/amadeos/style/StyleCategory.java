package org.datazuul.amadeos.style;

/**
 * The controls of the Style Manager, in the order of CDE's dtstyle.
 */
public enum StyleCategory {
    COLOR("Color", "Desktop color theme and icon theme", true),
    FONT("Font", "Font sizes of the desktop and applications", false),
    BACKDROP("Backdrop", "Wallpaper image or color of the desktop", true),
    KEYBOARD("Keyboard", "Key repeat and key click", false),
    MOUSE("Mouse", "Handedness, double-click speed and acceleration", false),
    BEEP("Beep", "Volume, tone and duration of the bell", false),
    SCREEN("Screen", "Screen saver and screen lock", true),
    WINDOW("Window", "Window focus and minimized window behaviour", false),
    STARTUP("Startup", "What the session restores at login", false);

    private final String label;
    private final String description;
    private final boolean available;

    StyleCategory(String label, String description, boolean available) {
        this.label = label;
        this.description = description;
        this.available = available;
    }

    public String label() {
        return label;
    }

    public String description() {
        return description;
    }

    /** False for controls that exist in CDE but are not implemented in amadeOS yet. */
    public boolean available() {
        return available;
    }
}
