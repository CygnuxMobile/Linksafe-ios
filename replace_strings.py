import re
import os

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()
    
    orig_text = text
    
    if filepath.endswith('.storyboard') or filepath.endswith('.xib'):
        text = re.sub(r'\b(text|title|placeholder)="([^"<\n]*?)LinkSafe(?!\sSite)([^"<\n]*?)"', r'\1="\2LinkSafe Site\3"', text)
    elif filepath.endswith('.m') or filepath.endswith('.h'):
        text = re.sub(r'@"([^"\n]*?)LinkSafe(?!\sSite)([^"\n]*?)"', r'@"\1LinkSafe Site\2"', text)
        
    if orig_text != text:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('/Users/aayushchodvadiya/Documents/iOS/23DigitalApp/Linksafe/iOS'):
    for file in files:
        if file.endswith(('.storyboard', '.xib', '.m', '.h')):
            process_file(os.path.join(root, file))

print("Done")
