#!/usr/bin/env python3
import argparse
import os
import zipfile
import sys
import unittest
import tempfile
import shutil

def extract_with_encoding(zip_path, encoding=None, output_dir="."):
    with zipfile.ZipFile(zip_path, 'r') as zf:
        for info in zf.infolist():
            raw_name = info.filename.encode("cp437")
            if encoding:
                try:
                    filename = raw_name.decode(encoding)
                except UnicodeDecodeError as e:
                    print(f"Warning: cannot decode {raw_name} with {encoding}: {e}", file=sys.stderr)
                    filename = raw_name.decode("utf-8", errors="replace")
            else:
                filename = raw_name.decode("utf-8", errors="replace")

            info.filename = filename
            target_path = os.path.join(output_dir, filename)
            os.makedirs(os.path.dirname(target_path), exist_ok=True)

            if not info.is_dir():
                with zf.open(info) as source, open(target_path, "wb") as target:
                    target.write(source.read())

def main():
    parser = argparse.ArgumentParser(description="Extract ZIP file with filename encoding conversion (like unzip-iconv).")
    parser.add_argument("zipfile", help="ZIP file to extract")
    parser.add_argument("-O", "--encoding", help="Input encoding of filenames (e.g., cp936, shift_jis, big5)", default=None)
    parser.add_argument("-d", "--directory", help="Target directory to extract files")
    parser.add_argument("-D", "--basename-dir", action="store_true",
                        help="Extract into directory with same basename as ZIP file")
    args = parser.parse_args()

    if args.basename_dir:
        base = os.path.splitext(os.path.basename(args.zipfile))[0]
        output_dir = os.path.join(".", base)
    elif args.directory:
        output_dir = args.directory
    else:
        output_dir = "."

    extract_with_encoding(args.zipfile, args.encoding, output_dir)


if __name__ == "__main__":
    main()


# ------------------ Self-Test Module ------------------

class SelfTest(unittest.TestCase):
    """
    Create a zip where the filenames stored are encoded as cp936 (GBK).
    We write the files by:
      - encoding the desired Unicode filename with 'cp936' (bytes),
      - decoding those bytes with 'cp437' to get an str that zipfile will accept,
        so the stored raw bytes in the archive equal the cp936 bytes.
    The extractor must then decode those raw bytes with -O 'cp936' into correct Unicode
    filenames on disk.
    """
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.zip_path = os.path.join(self.temp_dir, "test_cp936.zip")

        self.files = {
            "normal.txt": b"Hello World\n",
            "subdir/中文文件.txt": b"Chinese content\n"
        }

        # Build a zip where the raw stored filename bytes == fullname.encode('cp936')
        with zipfile.ZipFile(self.zip_path, 'w') as zf:
            for fullname, data in self.files.items():
                # desired raw bytes
                name_bytes = fullname.encode('cp936')
                # trick: decode these bytes as cp437 to get a str that, when zipfile writes,
                # will produce the exact raw bytes we encoded above.
                zf.writestr(name_bytes.decode('cp437'), data)

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    def test_extract_with_cp936(self):
        out_dir = os.path.join(self.temp_dir, "out_cp936")
        os.makedirs(out_dir, exist_ok=True)
        # IMPORTANT: we pass encoding='cp936' so filenames are decoded correctly to Unicode
        extract_with_encoding(self.zip_path, encoding="cp936", output_dir=out_dir)
        for fname in self.files.keys():
            self.assertTrue(os.path.exists(os.path.join(out_dir, fname)),
                            msg=f"Expected extracted file: {fname}")

    def test_extract_default_fallback(self):
        # If no encoding supplied, extractor will try cp437 then utf-8.
        out_dir = os.path.join(self.temp_dir, "out_default")
        os.makedirs(out_dir, exist_ok=True)
        extract_with_encoding(self.zip_path, encoding=None, output_dir=out_dir)
        self.assertTrue(os.path.exists(os.path.join(out_dir, "normal.txt")))

