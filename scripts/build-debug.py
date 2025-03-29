import os
import argparse
import subprocess

WIN_DATA = {
    'platform': 'win32_x64',
    'ext': 'exe',
    'sdl3': 'libs/win32_x64/SDL3.dll'
}

ARCH_ARR = {
    'win': WIN_DATA
}

outputDir = 'bin/debug/'

# 1. Read args for arch
parser = argparse.ArgumentParser(description="Build Odin project for different architectures.")
parser.add_argument("arch", choices=ARCH_ARR.keys(), help="Target architecture (win)")
parser.add_argument("target", help="Name of the target executable")
args = parser.parse_args()

output = f'{outputDir}{ARCH_ARR[args.arch]['platform']}'

# 2. Create output directory
os.makedirs(output, exist_ok=True)

# 4. Execute command
ext = ARCH_ARR[args.arch]['ext']
command = ['odin', 'run', './src/', f'--out:{output}/{args.target}.{ext}', '-debug']

try:
    subprocess.run(command)
except subprocess.CalledProcessError as e:
    print(f'Failed to build project {e}')