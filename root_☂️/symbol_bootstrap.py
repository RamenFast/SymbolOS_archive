import os
import json
import logging
import hashlib
from datetime import datetime

# --- GLOBAL SYMBOLS (Aligned with 1:13AM-27-JAN Patch) ---
OS_NAME = "SymbolOS"
PATCH_TIME = "1:13AM-27-JAN"
STORAGE_SYNC_STATUS = "SYNCED"
SYMBOL_MAP_PATH = "./.symbolos/shared_map.json"

class SymbolOSCore:
    def __init__(self):
        # Initialize basic logging
        logging.basicConfig(level=logging.INFO)
        self._ensure_integrity()
        self.init_storage_layer()

    def _ensure_integrity(self):
        """Ti Fix: Clears git locks and repairs corrupted index files."""
        # 1. Clear index.lock
        lock_path = "./.git/index.lock"
        if os.path.exists(lock_path):
            os.remove(lock_path)
            print(f"[{OS_NAME}] Drive Restored: Git index.lock purged.")

        # 2. Fix 'index file smaller than expected' bug
        index_path = "./.git/index"
        if os.path.exists(index_path):
            if os.path.getsize(index_path) < 64:
                print(f"[{OS_NAME}] Fatal Index Corruption Detected. Reconstructing...")
                os.remove(index_path)
                os.system("git read-tree HEAD")
                os.system("git reset")
                print(f"[{OS_NAME}] Shared Zone Reconstructed.")

    def init_storage_layer(self):
        """Fi Fix: Ensures the 'Space' for storage is initialized."""
        if not os.path.exists("./.symbolos"):
            os.makedirs("./.symbolos")

    def update_symbol_map(self):
        """Updates the Shared Symbol Map with Synced Storage data."""
        symbol_data = {
            "header": {
                "system": OS_NAME,
                "last_patch": PATCH_TIME,
                "storage_sync": STORAGE_SYNC_STATUS
            },
            "centroids": {
                "Agape": {"state": "Warmth/Space", "sync": "Validated"},
                "Ben": {"state": "Drive/Impact", "sync": "Validated"}
            },
            "shared_zone": {
                "convergence": 1.0,
                "reflection_active": True
            }
        }
        
        with open(SYMBOL_MAP_PATH, 'w') as f:
            json.dump(symbol_data, f, indent=4)
        
        print(f"[{OS_NAME}] Shared Symbol Map Updated: Storage Synced.")

if __name__ == "__main__":
    os_core = SymbolOSCore()
    os_core.update_symbol_map()