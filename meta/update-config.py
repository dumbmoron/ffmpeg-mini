#!/usr/bin/python3
import sys
import os.path

def read_things_stdin(suffix):
    things = []
    for thing in sys.stdin:
        thing = thing.strip()
        if thing:
            things.append(thing.strip().replace(f"_{suffix}", ""))
    return things

def read_things_config(path, thing):
    things = []
    with open(path, 'r') as file:
        for line in file:
            if '(' in line or ')' in line:
                continue
            things.append(
                line.replace('#', '').strip().replace(f"_{thing}", "")
            )
    return things

def diff(existing, new):
    return set(new) - set(existing)

def append_config(opt_diff, file_path, thing):
    lines = []
    with open(file_path, 'r') as file:
        lines = file.readlines()

    if ')\n' in lines:
        lines = lines[:lines.index(')\n')]

    if ')' in lines:
        lines = lines[:lines.index(')')]

    for entry in opt_diff:
        lines.append(f'#    {entry.replace(f"_{thing}", "")}\n')
    
    lines.append(')\n')

    with open(file_path, 'w') as file:
        file.write(''.join(lines))

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <config_dir> <thing>", file=sys.stderr)
        sys.exit(1)

    file_path = os.path.join(sys.argv[1], f"{sys.argv[2]}s.sh")
    opt_diff = diff(
        read_things_config(file_path, sys.argv[2]),
        read_things_stdin(sys.argv[2])
    )
    
    if len(opt_diff):
        append_config(opt_diff, file_path, sys.argv[2])
