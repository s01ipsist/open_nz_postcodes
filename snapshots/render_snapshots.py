#!/usr/bin/env python3
"""Render PNG snapshots per postcode boundary from PostGIS data."""
import argparse
import os
import random
from pathlib import Path

import geopandas as gpd
import matplotlib.patheffects as patheffects
import matplotlib.pyplot as plt
import psycopg2

PADDING_RATIO = 0.05
FIG_SIZE = (8, 8)
DPI = 150


def seeded_color(postcode):
    rng = random.Random(int(postcode))
    return (
        rng.randint(50, 255) / 255,
        rng.randint(100, 255) / 255,
        rng.randint(200, 255) / 255,
    )


def render(conn, postcode, out_dir):
    focal = gpd.read_postgis(
        "SELECT postcode, geom FROM postcode_boundaries WHERE postcode = %s",
        conn, params=(postcode,), geom_col="geom",
    )
    if focal.empty:
        print(f"!! no boundary for {postcode}")
        return

    minx, miny, maxx, maxy = (float(v) for v in focal.total_bounds)
    pad_x = (maxx - minx) * PADDING_RATIO
    pad_y = (maxy - miny) * PADDING_RATIO
    bbox = (minx - pad_x, miny - pad_y, maxx + pad_x, maxy + pad_y)

    boundaries = gpd.read_postgis(
        "SELECT postcode, geom FROM postcode_boundaries "
        "WHERE geom && ST_MakeEnvelope(%s, %s, %s, %s, 4326)",
        conn, params=bbox, geom_col="geom",
    )
    boundaries["fill"] = boundaries["postcode"].map(seeded_color)

    roads = gpd.read_postgis(
        "SELECT full_road_, geom FROM nz_roads "
        "WHERE geom && ST_MakeEnvelope(%s, %s, %s, %s, 4326)",
        conn, params=bbox, geom_col="geom",
    )

    fig, ax = plt.subplots(figsize=FIG_SIZE)
    boundaries.plot(ax=ax, color=boundaries["fill"], edgecolor="black", linewidth=0.4)
    if not roads.empty:
        roads.plot(ax=ax, color="black", linewidth=0.6)
    label_halo = [patheffects.withStroke(linewidth=2, foreground="white")]
    for _, row in boundaries.iterrows():
        pt = row.geom.representative_point()
        ax.annotate(
            row.postcode, (pt.x, pt.y), ha="center", va="center",
            fontsize=9, color="black", path_effects=label_halo,
        )

    ax.set_xlim(bbox[0], bbox[2])
    ax.set_ylim(bbox[1], bbox[3])
    ax.set_axis_off()
    fig.savefig(out_dir / f"{postcode}.png", dpi=DPI, bbox_inches="tight", pad_inches=0)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", default=Path(__file__).parent, type=Path)
    parser.add_argument("--postcode", nargs="*", help="postcodes to render (default: all)")
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    conn = psycopg2.connect(
        host=os.environ.get("PGHOST", "localhost"),
        user=os.environ.get("PGUSER", "postgres"),
        dbname="open_nz_postcodes",
    )
    try:
        if args.postcode:
            postcodes = args.postcode
        else:
            with conn.cursor() as cur:
                cur.execute("SELECT postcode FROM postcode_boundaries ORDER BY postcode")
                postcodes = [r[0] for r in cur.fetchall()]
        for pc in postcodes:
            print(pc)
            render(conn, pc, args.out)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
