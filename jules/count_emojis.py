import os
import re
from collections import Counter

# More robust emoji regex - using common ranges
emoji_pattern = re.compile(
    r'[\U0001F300-\U0001F64F]|[\U0001F680-\U0001F6FF]|[\u2600-\u26FF]|[\u2700-\u27BF]|[\U0001F900-\U0001F9FF]|[\U0001F1E6-\U0001F1FF]'
)

def count_emojis_in_repo():
    overall_counter = Counter()
    dir_stats = {}

    for root, dirs, files in os.walk('.'):
        if '.git' in root:
            continue

        current_dir_counter = Counter()
        for file in files:
            filepath = os.path.join(root, file)
            # Skip binary files if possible, though open(errors='ignore') handles it
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    emojis = emoji_pattern.findall(content)
                    current_dir_counter.update(emojis)
                    overall_counter.update(emojis)
            except Exception:
                continue

        # We want to record even directories with 0 emojis if they are top/second level
        # But for the report, we'll focus on the statistics
        dir_stats[root] = current_dir_counter

    return overall_counter, dir_stats

if __name__ == "__main__":
    overall, dirs = count_emojis_in_repo()

    print("## OVERALL STATS")
    print(f"Total Emojis Found: {sum(overall.values())}")
    print(f"Unique Emojis Used: {len(overall)}")
    print("\n## TOP 50 EMOJIS")
    for emoji, count in overall.most_common(50):
        print(f"{emoji}: {count}")

    print("\n## DIRECTORY BREAKDOWN (Recursive)")
    # Sort directories by path for legibility
    for dir_path in sorted(dirs.keys()):
        counter = dirs[dir_path]
        total = sum(counter.values())
        if total > 0 or dir_path.count(os.sep) <= 2:
            top_emojis = ", ".join([f"{e}({c})" for e, c in counter.most_common(10)])
            print(f"{dir_path} [{total}]: {top_emojis}")
