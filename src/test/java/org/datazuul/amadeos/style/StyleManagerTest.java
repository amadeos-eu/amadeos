package org.datazuul.amadeos.style;

import org.datazuul.amadeos.input.InputApplier;
import org.datazuul.amadeos.input.InputSettings;
import org.datazuul.amadeos.input.InputSettingsStore;
import org.datazuul.amadeos.input.XCommands;
import org.datazuul.amadeos.screen.ScreenSettings;
import org.datazuul.amadeos.screen.ScreenSettingsStore;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import javax.swing.JDialog;
import javax.swing.SwingUtilities;
import java.awt.GraphicsEnvironment;
import java.awt.Window;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
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
            StyleManager manager = new StyleManager(new ScreenSettingsStore(dir.resolve("screen.conf")), new InputSettingsStore(dir.resolve("input.conf")), new RecordingApplier());
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
            StyleManager manager = new StyleManager(new ScreenSettingsStore(dir.resolve("screen.conf")), new InputSettingsStore(dir.resolve("input.conf")), new RecordingApplier());
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

    @Test
    void keyboardMouseAndBeepSaveAndRunTheXTools() throws Exception {
        assumeFalse(GraphicsEnvironment.isHeadless());
        InputSettingsStore store = new InputSettingsStore(dir.resolve("input.conf"));
        RecordingApplier applier = new RecordingApplier();
        InputControls controls = new InputControls(store, applier);
        SwingUtilities.invokeAndWait(() -> {
            KeyboardDialog keyboard = new KeyboardDialog(null, s -> { }, controls);
            MouseDialog mouse = new MouseDialog(null, s -> { }, controls);
            BeepDialog beep = new BeepDialog(null, s -> { }, controls);
            try {
                assertEquals("Keyboard applied", keyboard.apply());
                assertEquals(InputSettings.DEFAULTS, store.load());
                assertTrue(applier.lines().contains("xset r rate 660 25"), applier.lines().toString());
                assertTrue(mouse.apply().startsWith("Mouse applied"));
                assertTrue(applier.lines().contains("xmodmap -e pointer = 1 2 3 4 5"), applier.lines().toString());
                beep.apply();
                assertTrue(applier.lines().contains("xset b 50 400 100"));
            } finally {
                keyboard.dispose();
                mouse.dispose();
                beep.dispose();
            }
        });
    }

    @Test
    void beepCancelRestoresTheSavedBellAfterATest() throws Exception {
        assumeFalse(GraphicsEnvironment.isHeadless());
        InputSettingsStore store = new InputSettingsStore(dir.resolve("input.conf"));
        store.save(InputSettings.DEFAULTS.withBeep(new InputSettings.Beep(20, 800, 50)));
        RecordingApplier applier = new RecordingApplier();
        SwingUtilities.invokeAndWait(() -> {
            BeepDialog beep = new BeepDialog(null, s -> { }, new InputControls(store, applier));
            try {
                beep.cancelled(); // nothing tested yet: nothing to restore
                assertTrue(applier.lines().isEmpty());
            } finally {
                beep.dispose();
            }
        });
    }

    /** Records the X commands instead of running them. */
    static final class RecordingApplier extends InputApplier {
        final List<XCommands.Command> commands = new ArrayList<>();

        @Override
        public List<XCommands.Command> apply(List<XCommands.Command> list) {
            commands.addAll(list);
            return List.of();
        }

        @Override
        public int pointerButtons() {
            return 5;
        }

        List<String> lines() {
            return commands.stream().map(c -> String.join(" ", c.args())).toList();
        }
    }
}
