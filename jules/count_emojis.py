import os
import re
from collections import Counter

# More comprehensive emoji regex using emoji property (if supported)
# or wider ranges to capture all variations.
# This regex targets common emoji blocks and variations.
emoji_pattern = re.compile(
    r'[\U0001F600-\U0001F64F]|' # Emoticons
    r'[\U0001F300-\U0001F5FF]|' # Misc Symbols and Pictographs
    r'[\U0001F680-\U0001F6FF]|' # Transport and Map
    r'[\U0001F1E6-\U0001F1FF]|' # Flags
    r'[\U0001F900-\U0001F9FF]|' # Supplemental Symbols and Pictographs
    r'[\U0001FA70-\U0001FAFF]|' # Symbols and Pictographs Extended-A
    r'[\u2600-\u26FF]|'         # Misc Symbols
    r'[\u2700-\u27BF]|'         # Dingbats
    r'[\uFE00-\uFE0F]|'         # Variation Selectors
    r'[\u200D]|'                 # Zero Width Joiner
    r'[\U0001F000-\U0001F02F]|' # Mahjong Tiles
    r'[\U0001F0A0-\U0001F0FF]|' # Playing Cards
    r'[\u203C\u2049\u2139\u2194-\u2199\u21A9-\u21AA\u231A-\u231B\u2328\u23CF\u23E9-\u23F3\u23F8-\u23FA\u24C2\u25AA-\u25AB\u25B6\u25C0\u25FB-\u25FE\u2600-\u2604\u260E\u2611\u2614-\u2615\u2618\u261D\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u2660\u2663\u2665-\u2666\u2668\u267B\u267F\u2692-\u2694\u2696-\u2697\u2699\u269B-\u269C\u26A0-\u26A1\u26AA-\u26AB\u26B0-\u26B1\u26BD-\u26BE\u26C4-\u26C5\u26C8\u26CE-\u26CF\u26D1\u26D3-\u26D4\u26E9-\u26EA\u26F0-\u26F5\u26F7-\u26FA\u26FD\u2702\u2705\u2708-\u2709\u270A-\u270B\u270C-\u270D\u270F\u2712\u2714\u2716\u271D\u2721\u2728\u2733-\u2734\u2744\u2747\u274C\u274E\u2753-\u2755\u2757\u2763-\u2764\u2795-\u2797\u27A1\u27B0\u27BF\u2934-\u2935\u2B05-\u2B07\u2B1B-\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299]'
)

# Refined regex that captures standard emojis and their variation selectors as a single unit
# Note: Python's re doesn't support \p{Emoji} without the 'regex' library, so we use ranges.
unified_emoji_pattern = re.compile(
    r'('
    r'(?:'
    r'[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E6-\U0001F1FF]|[\U0001F900-\U0001F9FF]|[\U0001FA70-\U0001FAFF]|[\u2600-\u26FF]|[\u2700-\u27BF]|[\u203C\u2049\u2139\u2194-\u2199\u21A9-\u21AA\u231A-\u231B\u2328\u23CF\u23E9-\u23F3\u23F8-\u23FA\u24C2\u25AA-\u25AB\u25B6\u25C0\u25FB-\u25FE\u2600-\u2604\u260E\u2611\u2614-\u2615\u2618\u261D\u2620\u2622\u2623\u2626\u262A\u262E\u262F\u2638-\u263A\u2640\u2642\u2648-\u2653\u2660\u2663\u2665-\u2666\u2668\u267B\u267F\u2692-\u2694\u2696-\u2697\u2699\u269B-\u269C\u26A0-\u26A1\u26AA-\u26AB\u26B0-\u26B1\u26BD-\u26BE\u26C4-\u26C5\u26C8\u26CE-\u26CF\u26D1\u26D3-\u26D4\u26E9-\u26EA\u26F0-\u26F5\u26F7-\u26FA\u26FD\u2702\u2705\u2708-\u2709\u270A-\u270B\u270C-\u270D\u270F\u2712\u2714\u2716\u271D\u2721\u2728\u2733-\u2734\u2744\u2747\u274C\u274E\u2753-\u2755\u2757\u2763-\u2764\u2795-\u2797\u27A1\u27B0\u27BF\u2934-\u2935\u2B05-\u2B07\u2B1B-\u2B1C\u2B50\u2B55\u3030\u303D\u3297\u3299]'
    r')'
    r'[\uFE00-\uFE0F\u200D]*[\U0001F3FB-\U0001F3FF]*' # Modifiers & ZWJ
    r')'
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
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    # Capture full emoji sequences
                    emojis = unified_emoji_pattern.findall(content)
                    current_dir_counter.update(emojis)
                    overall_counter.update(emojis)
            except Exception:
                continue

        dir_stats[root] = current_dir_counter

    return overall_counter, dir_stats

if __name__ == "__main__":
    overall, dirs = count_emojis_in_repo()

    # We strip variation selectors and ZWJ for counting, but the pattern captures them
    # to avoid fragmented counts. Let's normalize for the top-ten list report.
    normalized_counter = Counter()
    for emoji, count in overall.items():
        # Keep the emoji but remove variation selectors for the name mapping
        clean_emoji = emoji.replace('\ufe0f', '').replace('\ufe0e', '')
        normalized_counter[clean_emoji] += count

    print("## OVERALL STATS")
    print(f"Total Emojis Found: {sum(normalized_counter.values())}")
    print(f"Unique Emojis Used: {len(normalized_counter)}")
    print("\n## TOP 50 EMOJIS")
    for emoji, count in normalized_counter.most_common(50):
        print(f"{emoji}: {count}")

    print("\n## DIRECTORY BREAKDOWN (Recursive)")
    for dir_path in sorted(dirs.keys()):
        counter = dirs[dir_path]
        # Normalize dir counters too
        norm_dir_counter = Counter()
        for e, c in counter.items():
            norm_dir_counter[e.replace('\ufe0f', '').replace('\ufe0e', '')] += c

        total = sum(norm_dir_counter.values())
        if total > 0 or dir_path.count(os.sep) <= 2:
            top_emojis = ", ".join([f"{e}({c})" for e, c in norm_dir_counter.most_common(10)])
            print(f"{dir_path} [{total}]: {top_emojis}")
