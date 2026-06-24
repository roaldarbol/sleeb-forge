# sleeb-forge

Conda recipes for the CRAN R packages that the [sleep-staging
pipeline](https://github.com/animovement) depends on but that are **not yet
available on conda-forge**. Published to the
[sleeb-forge](https://prefix.dev/channels/sleeb-forge) channel on prefix.dev.

These are the changepoint-detection packages used by the segmentation step
(`tidychangepoint` and `fastcpd`, plus the two dependencies of `tidychangepoint`
that are also missing from conda-forge). Everything else the pipeline needs
(the `ani*` packages, the tidyverse/tidymodels stack, `changepoint`, `GA`, …)
already lives in its own channel or on conda-forge.

## Install

```bash
pixi add --channel https://prefix.dev/sleeb-forge --channel conda-forge r-tidychangepoint r-fastcpd
```

Or install an individual package:

```bash
pixi add --channel https://prefix.dev/sleeb-forge --channel conda-forge r-fastcpd
```

## Packages

| Package | Type | Description |
| --- | --- | --- |
| [r-tidychangepoint](recipes/tidychangepoint/recipe.yaml) | noarch | A tidy, unified interface for several changepoint-detection algorithms |
| [r-tidyclust](recipes/tidyclust/recipe.yaml) | noarch | A common (tidymodels) API to clustering |
| [r-fastcpd](recipes/fastcpd/recipe.yaml) | compiled | Fast change-point detection via sequential gradient descent |
| [r-changepointga](recipes/changepointga/recipe.yaml) | compiled | Changepoint detection via modified genetic algorithms (dep of tidychangepoint) |
| [r-wbs](recipes/wbs/recipe.yaml) | compiled | Wild Binary Segmentation for multiple change-point detection (dep of tidychangepoint) |

## How it works

Recipes are sourced from [CRAN](https://cran.r-project.org), with the version and
SHA256 **pinned** in each `recipe.yaml`. There is no auto-update job: bump a
version by editing the `version` and `sha256` fields by hand, then re-run the
build.

`r-tidychangepoint` is pure R and ships as a single `noarch` package. The other
three contain compiled code, so they are built natively on a per-platform runner
matrix (linux-64, osx-64, osx-arm64, win-64); the noarch package is uploaded
once, from the linux runner. `recipes/variants.yaml` points the Windows builds at
the mingw GNU toolchain (`gcc_win-64` / `gxx_win-64`) that R uses on Windows.

To trigger a build and upload, use the **Build and Upload** workflow dispatch on
GitHub Actions.

## Local development

Requires [pixi](https://pixi.sh).

```bash
# Build all packages for the current platform (rattler-build resolves order
# automatically). -m supplies the Windows mingw compiler mapping.
pixi run rattler-build build \
  --recipe-dir recipes \
  -m recipes/variants.yaml \
  -c https://prefix.dev/sleeb-forge \
  -c conda-forge \
  --output-dir output

# Build a single package
pixi run rattler-build build \
  --recipe recipes/fastcpd \
  -m recipes/variants.yaml \
  -c https://prefix.dev/sleeb-forge \
  -c conda-forge \
  --output-dir output
```
