# Assets Folder

## QR Code for Donations

To display the Revolut donation QR code in the Contact popup:

1. Save your Revolut QR code image as `revolut_qr.png` in this folder
2. The image should be a square format (recommended: 300x300 pixels or larger)
3. Supported formats: PNG (recommended), JPG, or BMP
4. The QR code will be displayed at 140x140 pixels in the popup

The app will automatically load the image if it exists at:
`assets\revolut_qr.png`

If the image is not found, the space will remain empty but the text "@jurajcy93" will still be visible.

## Desktop Shortcut Icon

To use a custom icon for the desktop shortcut:

1. Save your icon file as `desktop_icon.ico` in this folder
2. **Important**: Must be ICO format (Windows icon format)
3. Recommended sizes: 16x16, 32x32, 48x48, 256x256 (multi-size ICO)
4. The icon will be used when creating a desktop shortcut via Settings

The app will use the icon if it exists at:
`assets\desktop_icon.ico`

If the icon is not found, the default PowerShell icon will be used.

### Converting PNG to ICO

If you only have a PNG file, you can convert it online:
- https://convertio.co/png-ico/
- https://www.icoconverter.com/
- Or use Windows Paint 3D → Save As → ICO format
