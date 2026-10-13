package org.datazuul.amadeos.wm.theme.backdrop;

import org.datazuul.amadeos.wm.theme.WallpaperManager;
import org.junit.jupiter.api.Test;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class BackdropsTest {
    private static final Color SLATE = new Color(0x4A, 0x69, 0x84);

    @Test
    void everyBundledCdeBackdropDecodes() throws Exception {
        for (String file : Backdrops.CDE) {
            BufferedImage image = Backdrops.load(Backdrops.cdePath(file), SLATE);
            assertTrue(image.getWidth() > 0 && image.getHeight() > 0, file);
        }
        BufferedImage concave = Backdrops.load(Backdrops.cdePath("Concave.pm"), SLATE);
        assertEquals(8, concave.getWidth());
        assertEquals(1024, concave.getHeight());
        BufferedImage toronto = Backdrops.load(Backdrops.cdePath("Toronto.bm"), SLATE);
        assertEquals(213, toronto.getWidth());
        assertEquals(211, toronto.getHeight());
    }

    @Test
    void symbolicColoursFollowTheBackdropColour() throws Exception {
        MotifColors motif = MotifColors.of(SLATE);
        BufferedImage image = Backdrops.load(Backdrops.cdePath("Concave.pm"), SLATE);
        Set<Integer> used = colours(image);
        // Concave uses exactly the four shading symbols, none of its fallback greys.
        assertEquals(Set.of(motif.background().getRGB(), motif.topShadow().getRGB(),
                motif.bottomShadow().getRGB(), motif.select().getRGB()), used);

        BufferedImage red = Backdrops.load(Backdrops.cdePath("Concave.pm"), new Color(0x90, 0x20, 0x20));
        assertNotEquals(used, colours(red));
    }

    @Test
    void bitmapsUseBackgroundOnBottomShadowLikeDtwm() throws Exception {
        MotifColors motif = MotifColors.of(SLATE);
        BufferedImage foreground = Backdrops.load(Backdrops.cdePath("Foreground.bm"), SLATE);
        BufferedImage background = Backdrops.load(Backdrops.cdePath("Background.bm"), SLATE);
        assertEquals(Set.of(motif.background().getRGB()), colours(foreground));
        assertEquals(Set.of(motif.bottomShadow().getRGB()), colours(background));
    }

    @Test
    void xbmBitsAreReadLeastSignificantFirst() throws Exception {
        String source = "#define t_width 10\n#define t_height 2\nstatic char t_bits[] = {\n 0x01, 0x02, 0xff, 0x03 };\n";
        BufferedImage image = XbmDecoder.decode(source, Color.WHITE, Color.BLACK);
        int white = Color.WHITE.getRGB();
        int black = Color.BLACK.getRGB();
        assertEquals(white, image.getRGB(0, 0));
        assertEquals(black, image.getRGB(1, 0));
        assertEquals(white, image.getRGB(9, 0)); // second byte, bit 1
        assertEquals(black, image.getRGB(8, 0));
        assertEquals(white, image.getRGB(7, 1));
        assertEquals(white, image.getRGB(9, 1));
    }

    @Test
    void xpmColourKeysAndNamesAreResolved() throws Exception {
        String source = """
                /* XPM */
                static char *t[] = {
                "3 1 3 1",
                "a\tc red",
                "b s selectColor m white c #000000000000",
                "c c None",
                "abc"};
                """;
        BufferedImage plain = XpmDecoder.decode(source, null);
        assertEquals(Color.RED.getRGB(), plain.getRGB(0, 0));
        assertEquals(Color.BLACK.getRGB(), plain.getRGB(1, 0));
        assertEquals(0, plain.getRGB(2, 0) >>> 24, "None is transparent");

        BufferedImage mapped = XpmDecoder.decode(source, s -> s.equals("selectColor") ? Color.GREEN : null);
        assertEquals(Color.GREEN.getRGB(), mapped.getRGB(1, 0));
    }

    @Test
    void x11ColourSpecifications() {
        assertEquals(new Color(0x94, 0x94, 0x94), X11Colors.parse("#949494949494"));
        assertEquals(new Color(0xAB, 0xCD, 0xEF), X11Colors.parse("#ABCDEF"));
        assertEquals(Color.WHITE, X11Colors.parse("#fff"));
        assertEquals(Color.YELLOW, X11Colors.parse("yellow"));
        assertEquals(new Color(127, 127, 127), X11Colors.parse("gray50")); // rgb.txt: 7F
        assertNull(X11Colors.parse("no such colour"));
    }

    @Test
    void motifShadesAreOrderedAroundTheBackground() {
        for (Color bg : new Color[]{SLATE, new Color(20, 20, 30), new Color(240, 240, 235), new Color(0xAE, 0xB2, 0xC3)}) {
            MotifColors m = MotifColors.of(bg);
            assertTrue(lum(m.bottomShadow()) < lum(bg), "bottom shadow darker for " + bg);
            assertTrue(lum(m.topShadow()) != lum(bg), "top shadow differs for " + bg);
        }
        assertEquals(Color.WHITE, MotifColors.of(SLATE).foreground());
        assertEquals(Color.BLACK, MotifColors.of(new Color(240, 240, 235)).foreground());
    }

    @Test
    void wallpaperManagerListsAndLoadsTheCdeBackdrops() {
        var items = WallpaperManager.availableWallpapers();
        assertTrue(items.stream().anyMatch(i -> i.name().equals("Pebbles") && i.isPattern()));
        assertTrue(items.stream().anyMatch(i -> i.path().equals(WallpaperManager.NO_BACKDROP)));
        assertNotNull(WallpaperManager.loadImage(Backdrops.cdePath("Pebbles.pm"), SLATE));
        assertNull(WallpaperManager.loadImage(WallpaperManager.NO_BACKDROP, SLATE));
    }

    private static int lum(Color c) {
        return c.getRed() * 30 + c.getGreen() * 59 + c.getBlue() * 11;
    }

    private static Set<Integer> colours(BufferedImage image) {
        Set<Integer> set = new HashSet<>();
        for (int y = 0; y < image.getHeight(); y++) {
            for (int x = 0; x < image.getWidth(); x++) set.add(image.getRGB(x, y));
        }
        return set;
    }
}
