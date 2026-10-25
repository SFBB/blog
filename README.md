# SFBB's Blog

This is my personal blog, based on the [Jekyll Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) template.

* Blog URL: `https://sfbb.github.io/blog`

---

## 🚀 Local Build & Deploy

Whenever you want to build and publish the blog locally:

```bash
./deploy.sh
```

This script will:
1. Compile the Jekyll static site into `_site`.
2. Push the built HTML/CSS assets directly to the `gh-pages` branch.
3. Automatically clean up build artifacts.

---

## ⚙️ GitHub Pages Setup

In your GitHub repository settings:
* **Settings** -> **Pages** -> **Source**: Select `Deploy from a branch`
* **Branch**: Select `gh-pages` and `/ (root)`
