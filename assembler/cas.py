import re

LABEL_REGEX = re.compile("^\s*(\S+)\s*:(.*)$")

def get_label(line: str) -> [str]:
    match_result = LABEL_REGEX.match(line)

    if match_result:
        return [match_result.group(1), match_result.group(2).strip()]
    else:
        return ["", line.strip()]
    
