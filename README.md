# Termux-X

**Termux-X** adalah cyberpunk UI customizer untuk fresh install Termux.

Fokus project ini bukan menginstal hacking tools, tapi membuat pengalaman memakai Termux terasa lebih menarik, nyaman, dan estetik.

## Fitur

- Header ASCII `Termux-X`
- Cyberpunk terminal color scheme
- Zsh sebagai shell experience utama
- Custom prompt minimalis
- Startup dashboard
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- Extra keys yang lebih nyaman untuk Android
- Wizard otomatis step-by-step
- Error log otomatis
- Continue-on-error agar proses tidak berhenti total saat step non-fatal gagal

## Struktur Project

```txt
termux-x/
├── install.sh
├── assets/
│   ├── banner.txt
│   ├── colors.properties
│   ├── termux.properties
│   └── zshrc.template
├── lib/
│   ├── ui.sh
│   ├── logger.sh
│   ├── checks.sh
│   ├── theme.sh
│   ├── zsh.sh
│   └── plugins.sh
└── README.md
```

## Cara Install dari Folder Lokal

```bash
chmod +x install.sh
./install.sh
```

Setelah selesai, restart Termux.

## Cara Install via GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/whitehat57/termux-x/main/bootstrap.sh | bash

## File yang Diubah

Installer akan membuat/mengubah file berikut:

```txt
~/.zshrc
~/.bashrc
~/.termux/colors.properties
~/.termux/termux.properties
~/.termux-x/
```

File lama akan dicadangkan otomatis ke:

```txt
~/.termux-x/backups/
```

## Log

Setiap proses instalasi disimpan ke:

```txt
~/.termux-x/logs/
```

Log terbaru tersedia di:

```txt
~/.termux-x/logs/latest.log
```

## Catatan Desain

Termux-X sengaja dibuat ringan:

- Tidak memakai Oh My Zsh di versi awal
- Plugin Zsh di-source manual
- Startup dashboard dibuat sederhana
- Tidak memasang tool berat
- Tidak butuh root

Tujuan utamanya adalah membuat Termux fresh install terasa lebih hidup tanpa mengorbankan performa.

## Troubleshooting

### Warna belum berubah

Jalankan:

```bash
termux-reload-settings
```

Atau restart Termux.

### Zsh belum otomatis terbuka

Jalankan:

```bash
zsh
```

Lalu cek apakah `.bashrc` sudah memiliki blok:

```bash
# >>> TERMUX-X ZSH BOOTSTRAP >>>
```

### Plugin tidak aktif

Cek folder:

```bash
ls ~/.termux-x/plugins
```

Harus ada:

```txt
zsh-autosuggestions
zsh-syntax-highlighting
```

Jika belum ada, jalankan ulang:

```bash
./install.sh
```
