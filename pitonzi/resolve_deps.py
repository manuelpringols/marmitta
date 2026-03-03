#!/usr/bin/env python3

import sys
import os
import ast
import importlib.util
import sysconfig
import hashlib
import json
from functools import lru_cache

CUSTOM_MAP = {
    # === Security / Networking ===
    'nmap': 'python-nmap',
    'impacket': 'impacket',
    'smb': 'impacket',
    'Crypto': 'pycryptodome',
    'cryptography': 'cryptography',
    'paramiko': 'paramiko',
    'scapy': 'scapy',
    'pcapy': 'pcapy',
    'netaddr': 'netaddr',
    'IPy': 'IPy',
    'requests_ntlm': 'requests-ntlm',
    'bs4': 'beautifulsoup4',
    'twisted': 'twisted',

    # === Data science ===
    'PIL': 'Pillow',
    'cv2': 'opencv-python',
    'sklearn': 'scikit-learn',
    'yaml': 'PyYAML',
    'pymysql': 'PyMySQL',
    'MySQLdb': 'mysqlclient',
    'pymssql': 'pymssql',
    'psycopg2': 'psycopg2-binary',
    'matplotlib': 'matplotlib',
    'seaborn': 'seaborn',
    'pandas': 'pandas',
    'numpy': 'numpy',
    'scipy': 'scipy',
    'skimage': 'scikit-image',
    'lxml': 'lxml',

    # === Web / APIs ===
    'flask': 'Flask',
    'django': 'Django',
    'jinja2': 'Jinja2',
    'werkzeug': 'Werkzeug',
    'fastapi': 'fastapi',
    'starlette': 'starlette',
    'uvicorn': 'uvicorn',

    # === Others ===
    'serial': 'pyserial',
    'OpenSSL': 'pyOpenSSL',
    'dateutil': 'python-dateutil',
    'setuptools': 'setuptools',
    'pip': 'pip',
    'colorama': 'colorama',
    'termcolor': 'termcolor',
    'tabulate': 'tabulate',
    'docopt': 'docopt',
    'PyQt5': 'PyQt5',
    'PySide2': 'PySide2',
    'pygame': 'pygame',
    'pytz': 'pytz',
    'regex': 'regex',
    'tkinter': 'tk',  # NB: su Linux è spesso un pacchetto di sistema (python3-tk)
    'dotenv': 'python-dotenv',
    'jinja2': 'Jinja2',
    'bcrypt': 'bcrypt',
    'aiohttp': 'aiohttp',
    'asyncio': 'asyncio',  # built-in in >=3.4, ignora se builtin
    'pytest': 'pytest',
    'coverage': 'coverage',
}

CACHE_DIR = os.path.expanduser('~/.cache/resolve_deps')
os.makedirs(CACHE_DIR, exist_ok=True)

# Precalcola i percorsi stdlib
STDLIB_PATHS = {
    os.path.realpath(sysconfig.get_paths()['stdlib']),
    os.path.realpath(sysconfig.get_paths().get('platstdlib', '')),
}

@lru_cache(maxsize=None)
def is_builtin_or_stdlib(mod_name):
    try:
        if mod_name in sys.builtin_module_names:
            return True

        spec = importlib.util.find_spec(mod_name)
        if spec is None:
            return False

        if spec.origin in (None, 'built-in', 'frozen'):
            return True

        origin = os.path.realpath(spec.origin)

        # Escludi site-packages e dist-packages
        if any(x in origin for x in ('site-packages', 'dist-packages')):
            return False

        return any(origin.startswith(stdlib_path) for stdlib_path in STDLIB_PATHS)
    except Exception:
        return False

def extract_imports_from_ast(content):
    modules = set()
    try:
        tree = ast.parse(content)
    except Exception:
        return modules

    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                mod = alias.name.split('.')[0]
                modules.add(mod)
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                mod = node.module.split('.')[0]
                modules.add(mod)
    return modules

def file_hash(filepath):
    h = hashlib.sha256()
    with open(filepath, 'rb') as f:
        while chunk := f.read(8192):
            h.update(chunk)
    return h.hexdigest()

def cache_get(filepath):
    h = file_hash(filepath)
    cache_file = os.path.join(CACHE_DIR, h + '.json')
    if os.path.isfile(cache_file):
        try:
            with open(cache_file, 'r') as f:
                data = json.load(f)
                return set(data.get('deps', []))
        except Exception:
            return None
    return None

def cache_set(filepath, deps):
    h = file_hash(filepath)
    cache_file = os.path.join(CACHE_DIR, h + '.json')
    data = {'deps': list(deps)}
    try:
        with open(cache_file, 'w') as f:
            json.dump(data, f)
    except Exception:
        pass

def extract_imports(filepath):
    cached = cache_get(filepath)
    if cached is not None:
        return cached

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    modules = extract_imports_from_ast(content)

    cleaned = set()
    for mod in modules:
        if mod and not is_builtin_or_stdlib(mod):
            cleaned.add(CUSTOM_MAP.get(mod, mod))

    cache_set(filepath, cleaned)
    return cleaned

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: resolve_deps.py <script.py>", file=sys.stderr)
        sys.exit(1)

    deps = extract_imports(sys.argv[1])
    if deps:
        print(' '.join(sorted(deps)))
    else:
        print("Nessuna dipendenza esterna trovata. xD", file=sys.stderr)
