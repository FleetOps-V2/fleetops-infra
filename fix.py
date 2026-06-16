import os
import re

for root, _, files in os.walk('terraform/modules'):
    for f in files:
        if f.endswith('.tf'):
            path = os.path.join(root, f)
            with open(path, 'r', encoding='utf-8') as file:
                content = file.read()
                
            # ECR line 55
            content = content.replace('{ tagStatus = "tagged"; tagPrefixList = ["v", "latest"]; countType = "imageCountMoreThan"; countNumber = 10 }', '{\n      tagStatus = "tagged"\n      tagPrefixList = ["v", "latest"]\n      countType = "imageCountMoreThan"\n      countNumber = 10\n    }')
            
            # EFS line 47
            content = content.replace('{ owner_uid = 1000; owner_gid = 1000; permissions = "755" }', '{\n      owner_uid = 1000\n      owner_gid = 1000\n      permissions = "755"\n    }')
            
            # Helm set blocks
            content = re.sub(r'set \{\s*name = "([^"]+)"\n\s*value = ([^\n]+)\n\s*\}', r'set {\n    name = "\1"\n    value = \2\n  }', content)
            
            with open(path, 'w', encoding='utf-8') as file:
                file.write(content)
