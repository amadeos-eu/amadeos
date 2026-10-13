package org.datazuul.amadeos.style;

import org.datazuul.amadeos.screen.ScreenSettings;
import org.datazuul.amadeos.screen.ScreenSettingsStore;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import javax.swing.JDialog;
import javax.swing.SwingUtilities;
import java.awt.GraphicsEnvironment;
import java.awt.Window;
import java.nio.file.Path;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.*;
import static org.junit.jupiter.api.Assumptions.assumeFalse;

class StyleManagerTest {
    @TempDir
    Path dir;

    @Test
    void showsAllCdeControlsAndEnablesTheImplementedOnes() throws Exception {
        assumeFalse(GraphicsEnvironment.isHeadless());
        SwingUtilities.invokeAndWait(() -> {
            StyleManager manager = new StyleManager(new ScreenSettingsStore(dir.resolve("screen.conf")));
            try {
                for (StyleCategory category : StyleCategory.values()) {
                    assertEquals(category.available(), manager.button(category).isEnabled(), category.name());
                    assertEquals(category.label(), manager.button(category).getText());
                }
                assertEquals("Style Manager", manager.getTitle());
            } finally {
                manager.dispose();
            }
        });
    }

    @Test
    void screenDialogSavesTheSettings() throws Exception {
        assumeFalse(GraphicsEnvironment.isHeadless());
        ScreenSettingsStore store = new ScreenSettingsStore(dir.resolve("screen.conf"));
        AtomicReference<String> status = new AtomicReference<>();
        SwingUtilities.invokeAndWait(() -> {
            ScreenDialog dialog = new ScreenDialog(null, status::set, store);
            try {
                String message = dialog.apply();
                status.set(message);
                assertEquals(ScreenSettings.DEFAULTS, store.load());
            } finally {
                dialog.dispose();
            }
        });
        assertTrue(status.get().startsWith("Screen: saver after 10 min"), status.get());
    }

    @Test
    void openingAControlTwiceReusesTheDialog() throws Exception {
        assumeFalse(GraphicsEnvironment.isHeadless());
        SwingUtilities.invokeAndWait(() -> {
            StyleManager manager = new StyleManager(new ScreenSettingsStore(dir.resolve("screen.conf")));
            try {
                manager.openControl(StyleCategory.SCREEN);
                manager.openControl(StyleCategory.SCREEN);
                long dialogs = java.util.Arrays.stream(Window.getWindows())
                        .filter(w -> w instanceof JDialog && w.isDisplayable() && w.getOwner() == manager)
                        .count();
                assertEquals(1L, dialogs);
                manager.openControl(StyleCategory.FONT); // not available: no dialog, no exception
            } finally {
                for (Window w : manager.getOwnedWindows()) w.dispose();
                manager.dispose();
            }
        });
    }
}
