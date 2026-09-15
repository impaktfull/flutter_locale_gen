#!/usr/bin/env python3
"""Captures simulator screenshots and turns them into a framed GIF.

    simulator_gif.py capture <udid> <frames-dir>   # until <frames-dir>/stop exists
    simulator_gif.py build <frames-dir> <out.gif> <out.png>
"""
import glob
import os
import subprocess
import sys
import time

from PIL import Image, ImageChops, ImageDraw, ImageFilter

BACKGROUND = (123, 97, 255)
PHONE_WIDTH = 390
CORNER_RADIUS = 52
PADDING = 44
LAST_FRAME_MS = 2000


def capture(udid, frames_dir):
    stop = os.path.join(frames_dir, "stop")
    while not os.path.exists(stop):
        path = os.path.join(frames_dir, f"{int(time.time() * 1000)}.png")
        subprocess.run(
            ["xcrun", "simctl", "io", udid, "screenshot", path],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def frame(screenshot):
    phone_height = round(screenshot.height * PHONE_WIDTH / screenshot.width)
    phone = screenshot.convert("RGB").resize(
        (PHONE_WIDTH, phone_height), Image.LANCZOS
    )
    mask = Image.new("L", phone.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, *phone.size), CORNER_RADIUS, fill=255
    )

    canvas_size = (PHONE_WIDTH + 2 * PADDING, phone_height + 2 * PADDING)
    canvas = Image.new("RGB", canvas_size, BACKGROUND)
    shadow = Image.new("L", canvas_size, 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (PADDING, PADDING + 10, PADDING + PHONE_WIDTH, PADDING + phone_height + 10),
        CORNER_RADIUS,
        fill=110,
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))
    canvas.paste((40, 20, 120), (0, 0), shadow)
    canvas.paste(phone, (PADDING, PADDING), mask)
    return canvas


def build(frames_dir, out_gif, out_png):
    paths = sorted(
        glob.glob(os.path.join(frames_dir, "*.png")),
        key=lambda p: int(os.path.splitext(os.path.basename(p))[0]),
    )
    if not paths:
        raise SystemExit("no frames captured")
    stamps = [int(os.path.splitext(os.path.basename(p))[0]) for p in paths]

    frames, durations = [], []
    for i, path in enumerate(paths):
        image = frame(Image.open(path))
        duration = stamps[i + 1] - stamps[i] if i + 1 < len(paths) else LAST_FRAME_MS
        if frames and ImageChops.difference(frames[-1], image).getbbox() is None:
            durations[-1] += duration
            continue
        frames.append(image)
        durations.append(duration)

    frames[-1].save(out_png, optimize=True)
    palette_source = frames[-1].quantize(colors=160, method=Image.MEDIANCUT)
    quantized = [
        f.quantize(palette=palette_source, dither=Image.NONE) for f in frames
    ]
    quantized[0].save(
        out_gif,
        save_all=True,
        append_images=quantized[1:],
        duration=durations,
        loop=0,
        optimize=True,
        disposal=1,
    )
    print(f"{out_gif}: {len(frames)} frames, {sum(durations) / 1000:.1f}s")


if __name__ == "__main__":
    command, *args = sys.argv[1:]
    {"capture": capture, "build": build}[command](*args)
