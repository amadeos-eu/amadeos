package org.datazuul.amadeos.wm.theme.backdrop;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Locale;

/**
 * CDE backdrops: the original pattern tiles from the CDE sources (LGPL, see
 * {@code /backdrops/cde/COPYING}) and the loader for {@code .pm/.xpm} and {@code .bm/.xbm} files.
 *
 * <p>Patterns are coloured the way dtwm colours them from the workspace colour set: symbolic XPM colours
 * ({@code background}, {@code topShadowColor}, ...) come from {@link MotifColors} of the backdrop colour,
 * and bitmaps are drawn with the set's background (set bits) on its bottom shadow (clear bits).
 */
public final class Backdrops {
    /** Classpath folder of the bundled CDE backdrops. */
    public static final String CDE_RESOURCE_DIR = "/backdrops/cde/";
    /** Path prefix that {@code WallpaperManager} uses for classpath resources. */
    public static final String CLASSPATH = "classpath:";

    /**
     * The CDE 2.x backdrops, minus NoBackdrop (amadeOS offers a plain colour instead) and SunLogo
     * (a vendor trademark).
     */
    public static final List<String> CDE = List.of(
            "Ankh.bm", "Background.bm", "BrickWall.bm", "Concave.pm", "Convex.pm", "Corduroy.pm",
            "Crochet.pm", "Foreground.bm", "InlayColor.pm", "InlayPlain.pm", "KnitLight.pm", "Lattice.pm",
            "LatticeBig.pm", "Leaves.pm", "OldChars.pm", "Paver.pm", "Pebbles.pm", "PinStripe.pm",
            "RakedSand.bm", "RicePaper.pm", "SkyDark.pm", "SkyLight.pm", "Sprinkles.pm", "Toronto.bm",
            "WaterDrops.pm", "Wooly.pm");

    private Backdrops() {
    }

    /** The path under which {@code WallpaperManager} finds a bundled CDE backdrop. */
    public static String cdePath(String file) {
        return CLASSPATH + CDE_RESOURCE_DIR + file;
    }

    /** The name dtstyle shows: the file name without extension. */
    public static String displayName(String file) {
        String name = Path.of(file).getFileName().toString();
        int dot = name.lastIndexOf('.');
        return dot > 0 ? name.substring(0, dot) : name;
    }

    /** Whether the path is an X pixmap or bitmap, i.e. a pattern that is coloured and tiled. */
    public static boolean isPattern(String path) {
        if (path == null) return false;
        String p = path.toLowerCase(Locale.ROOT);
        return p.endsWith(".pm") || p.endsWith(".xpm") || p.endsWith(".bm") || p.endsWith(".xbm");
    }

    /** Loads a pattern from a file or {@code classpath:} path and colours it with the backdrop colour. */
    public static BufferedImage load(String path, Color color) throws IOException {
        return decode(path, read(path), color);
    }

    static BufferedImage decode(String name, String source, Color color) throws IOException {
        MotifColors colors = MotifColors.of(color);
        String lower = name.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".bm") || lower.endsWith(".xbm") || source.contains("_bits[]")) {
            return XbmDecoder.decode(source, colors.background(), colors.bottomShadow());
        }
        return flatten(XpmDecoder.decode(source, colors::symbol), colors.bottomShadow());
    }

    private static String read(String path) throws IOException {
        if (path.startsWith(CLASSPATH)) {
            String resource = path.substring(CLASSPATH.length());
            try (InputStream in = Backdrops.class.getResourceAsStream(resource)) {
                if (in == null) throw new IOException("no such backdrop: " + path);
                return new String(in.readAllBytes(), StandardCharsets.ISO_8859_1);
            }
        }
        return Files.readString(Path.of(path), StandardCharsets.ISO_8859_1);
    }

    /** Transparent pixels ("None") show the backdrop's base colour, as on the root window. */
    private static BufferedImage flatten(BufferedImage image, Color under) {
        BufferedImage out = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = out.createGraphics();
        g.setColor(under);
        g.fillRect(0, 0, out.getWidth(), out.getHeight());
        g.drawImage(image, 0, 0, null);
        g.dispose();
        return out;
    }
}
