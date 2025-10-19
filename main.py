# Import required libraries
import uuid
import os
import yaml
from jinja2 import Environment, FileSystemLoader
import webbrowser
import subprocess

# Load your data from YAML
with open('data.yaml', 'r') as f:
    data = yaml.safe_load(f)

# Setup Jinja2 environment with loader pointing to the templates directory
env = Environment(loader=FileSystemLoader('template'))

# Load your index.html template (which extends base.html)
template = env.get_template('index.html')

# Render the template with data
def replace_tags(text):
    output = []
    stack = []
    i = 0
    while i < len(text):
        if text[i:i+2] == '<%':
            if stack:
                raise ValueError("Nested or overlapping '<%' found at position {}".format(i))
            stack.append(i)
            output.append('<b>')
            i += 2
        elif text[i:i+2] == '%>':
            if not stack:
                raise ValueError("Unmatched '%>' found at position {}".format(i))
            stack.pop()
            output.append('</b>')
            i += 2
        else:
            output.append(text[i])
            i += 1

    if stack:
        raise ValueError("Unmatched '<%' found at position {}".format(stack[-1]))

    return ''.join(output)


rendered = replace_tags(template.render(data=data))

build_uuid = str(uuid.uuid4())

# Ensure build directory exists
build_directory = os.path.join(os.getcwd(), "build", build_uuid)
os.makedirs(build_directory, exist_ok=True)

# Generate unique filename
filename = os.path.join(build_directory, "resume.html")

# Write rendered content to file
with open(filename, 'w', encoding='utf-8') as f:
    f.write(rendered)

print(f"Rendered HTML saved to {filename}")


html_file = filename
output_pdf = os.path.join(build_directory, "resume.pdf")

chrome_path = "/run/current-system/sw/bin/google-chrome-stable"

# Run Chrome headless to print to PDF
subprocess.run([
    chrome_path,
    "--headless",
    "--disable-gpu",
    f"--print-to-pdf={output_pdf}",
    "--no-margins",
    f"file:///{html_file}"
])

print(f"PDF saved to: {output_pdf}")
