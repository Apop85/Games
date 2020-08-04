# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['txtAdventure_procedural_journey.py'],
             pathex=['C:\\Windows\\System32\\downlevel', 'D:\\Schuldokumente\\__github\\Games\\Prototypes\\random_journey'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='txtAdventure_procedural_journey',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          upx_exclude=[],
          runtime_tmpdir=None,
          console=True , icon='app.ico')
