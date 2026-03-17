#!/usr/bin/env python3
import argparse
import subprocess
import sys
import time
import re

def find_tsc_printer():
    """查找名称中包含 TSC 的打印机，找不到则退出"""
    try:
        result = subprocess.check_output(["lpstat", "-v"], stderr=subprocess.DEVNULL).decode()
        # 匹配 device for 打印机名: 路径
        match = re.search(r"device for (.*TSC.*?):", result, re.IGNORECASE)
        if match:
            return match.group(1).strip()
        else:
            print("错误: 未找到名称包含 'TSC' 的打印机。程序自动退出。", file=sys.stderr)
            sys.exit(1)
    except subprocess.CalledProcessError:
        print("错误: 无法运行 lpstat，请检查 CUPS 是否安装。", file=sys.stderr)
        sys.exit(1)

def init_printer_hardware(printer_name, width, height, gap):
    """发送 TSPL 指令初始化硬件参数"""
    tspl_cmd_list = [
        f"SIZE {width} mm, {height} mm",
        f"GAP {gap} mm, 0 if gap else AUTODETECT",
        "DIRECTION 1",
        "CLS"
    ]
    # if gap == "0" or gap.lower() == "auto":
        # tspl_cmd = f"SIZE {width} mm, {height} mm\nAUTODETECT\n"
    # else:
        # tspl_cmd = f"SIZE {width} mm, {height} mm\nGAP {gap} mm, 0\n"
    # tspl_cmd += f"DIRECTION 1\nOFFSET {v_offset} mm\nCLS\n"
    tspl_cmd = "\n".join(tspl_cmd_list)
    print(f"[*] 初始化硬件: {width}x{height}mm, 间隙: {gap}")
    process = subprocess.Popen(["lp", "-d", printer_name, "-o", "raw"], stdin=subprocess.PIPE)
    process.communicate(input=tspl_cmd.encode())
    time.sleep(0.8) # 预留物理响应时间

def print_pdf(printer_name, pdf_file, width, height, v_offset, copies, pages, scale):
    """通过 CUPS 打印 PDF 文档"""
    lp_args = ["lp", "-d", printer_name, "-n", str(copies)]
    # 页面尺寸
    lp_args.extend(["-o", f"media=Custom.{width}x{height}mm"])
    if v_offset:
        lp_args.extend(["-o", f"VerticalOffset={v_offset}mm"])
    # 页码范围
    if pages:
        lp_args.extend(["-P", pages])
    # 缩放处理
    if scale.isdigit():
        lp_args.extend(["-o", f"scaling={scale}"])
    else:
        lp_args.extend(["-o", "fit-to-page"])
    lp_args.append(pdf_file)
    print(f"[*] cmd: {' '.join(lp_args)}")
    print(f"[*] 提交打印任务: {pdf_file} (份数: {copies}，页码范围：{pages})")
    subprocess.run(lp_args)

def parse_size(size_str):
    """解析 60x30 格式的字符串"""
    try:
        w, h = size_str.lower().split('x')
        return w.strip(), h.strip()
    except ValueError:
        raise argparse.ArgumentTypeError("尺寸格式必须为 '宽度x高度' (例如: 40x30)")

def main():
    parser = argparse.ArgumentParser(
        description="TSC 标签打印工具 (Linux/CUPS)",
        add_help=True
    )
    # 必选参数
    parser.add_argument("pdf", help="要打印的 PDF 文件路径")
    # 可选参数
    parser.add_argument("-s", "--size", type=parse_size, default="60x30", 
                        help="标签尺寸 '宽x高'，单位mm (默认: 60x30)")
    parser.add_argument("-g", "--gap", default="auto", 
                        help="间隙距离，单位mm (默认: auto)")
    parser.add_argument("-v", "--voffset", default="0", 
                        help="垂直偏移，单位mm (默认: 0)，正数表示向上偏移")
    parser.add_argument("-n", "--copies", type=int, default=1, 
                        help="打印份数 (默认: 1)")
    parser.add_argument("-p", "--pages", default=None,
                        help="页码范围 (例如: 1-3, 5)，默认为None，即全部页面")
    parser.add_argument("--scale", default="fit-to-page", 
                        help="缩放比例 1-100 或 'fit-to-page' (默认: fit-to-page)")
    # 处理参数错误导致的非0退出
    try:
        args = parser.parse_args()
    except SystemExit:
        # 如果是 -h/--help，argparse 会自动以 0 退出
        # 如果是参数错误，argparse 会自动以 2 退出
        raise
    # 1. 查找打印机 (找不到则脚本内 sys.exit(1))
    printer = find_tsc_printer()
    print(f"[*] 找到打印机: {printer}")
    # 2. 硬件初始化
    init_printer_hardware(printer, args.size[0], args.size[1], args.gap)
    # 3. 打印 PDF
    print_pdf(printer, args.pdf, args.size[0], args.size[1], args.voffset, args.copies, args.pages, args.scale)

if __name__ == "__main__":
    main()
