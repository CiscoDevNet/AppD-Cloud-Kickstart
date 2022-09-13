#!/bin/sh -eux
# appdynamics terraform cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-centos}"
aws_ec2_hostname="${aws_ec2_hostname:-terraform-user}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"
use_aws_ec2_num_suffix="${use_aws_ec2_num_suffix:-true}"

# [OPTIONAL] aws cli config parameters [w/ defaults].
aws_cli_default_region_name="${aws_cli_default_region_name:-us-east-1}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="AppD-Cloud-Kickstart"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCEyVAKfQ/Oq2Cov6ZiGfEI3N2Rz3QG1oVQbz9mYZZMYoDpt67nov+wVDUuham7MG30jgQwMoyGSVUP0ol2R+IDyg+dzSS/XEByrA7IUlLLcYZY8d8VqJOKzoqImfSpTfE0ObbkuYiR1RgOCnQkaH3oHOHpQtse5YxTFdohOaEFlvkAAVe4kSU4/FrxcO1+AL+5CFbl0FqffvqdwNABYd+dNKXylO6rhrMz/v/xAltH2gycj0Xc7c5IGPAqhR08Ei4Q/rTNQeARrUAvkH+LwWP73lAzJNnvgDiGmUegA8ZnlMhvK1dSUftZ72HhO1lG05Q2Rm4U1F0wG+a0fm352Aif AppD-Cloud-Kickstart"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# cloud9 public keys from cisco run-on aws account for ed barberis. ["us-east-1", "us-east-2", "us-west-1", "us-west2"]
aws_cloud9_public_key_01="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOCEHU0ygOHaI7u6F3AUFbjJuB6+urympwYHcwyWRArCse9ZIHdPltaNuUbxYvAWxwG+gSviy28BZlwDOOLCD3VEVexdDFpEh2qBzEf+OaVh9kwlNqBPoHaZL7cTbsRb5vlFWK/01jUgKnI2jathARN4/sn56neJ36KpfMfCwtOjpBYzjQ9nIVEC9m5ZAOdCtPdh+Lco1IgL2ug2qP9273oflSYw90sCw9znuYjowOsigAilhGlenLZYeql/s5QjGlffrke2w0z9Ux7Tr6EULDJHs1JgfLsLmk2kuOq3C9706CIjyQyecRfgPyHTVfPBzXjButJKHTFl6awc14MQuT0wF7DFe2wQGmhFG93FXNHg87BYnH88fWMpeUcI1Agr6GV46nmPJpR+h+adaZSDphe/3RUsSoiXENXZB4ASYAyK1xhFlQxgbk3s/JlLlht6l1HMvYbw/FFi9VlIbaAlJH3+qeOEgzsRzTm1S20VRgPxtQX+Hw3NTOGfxcwE9XyAPAndc6mPSJ7Vtg+36PauLZgQ5M8TEotpjtBDGXAjpAOz7k0S5nKVyrUD5+X14QLXTF9KmcdQx8fv1F1N6zMLT39cNJxpXskmwwovE4JcB2X/scx60Ae/R0ELC3e/r9R3L964yosTmrPWD70ken20pGJSG4FuZOk9wT3SDfGQxTqQ== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_02="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCauKkcd0elSHLJD2ViHuhKcROo5yvFuvmIcsyvFJSi930w8LdIYaqgq5MGhDkQl5ZBBQvDRJNyq1UsvjPPNd/C5PPlQw1kxYv2MSyVClvlxB86ndRFV5pCkMzuff7sI/rDlI5Za4UeLim2BMYswc7mt2wxsJDyPJFazlU1W+D/zCSG+Yb6SYu5YXU4CSdAUTrbhYkACad8FdJDJHrlAscZJ4XAgnm+kFXhjKsUkOKksjiJQPNMg5f1eQfrBySxWtiU9J6Jbd+w89zNuTMuLcZDEU3G+1uq3RMerezvuL6ZZ6aTddlNT4jmBWYSpz040g/sscV+SctXORBRexjGQF4b9AZOlGmCB4eRvpNhtnsgjNbY1l8RrQDV9IJyJc+Ys9YO+EhpjoMmHvkmMeUiQMkh3SPimribaA2TJ4U4p8R2W5WQSOksAz3AXE7EZRSRY9+CfSRzv3ywgJafnXCY2GwLWYPeYku5Jko0JKT991pxNTctU0NChcjhI/UFviuZNIZsG8IP44RBwd4k0CXbxVeKpzJLSzxaNQsNkdgn/QeL0lEXDBIXWAO1U/dYL5BMl0HLx/Vjc1Vh041+roBHiP5E3IgMNLKBZHmfMtDXkgv7NL4zi/4Om0v+QSOPns5JQIAWQ92HmooCHq0rIg29sItN4+4q6Xc7GV3nHYcoNTtBnw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_03="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXAgvFPH5MJa0P2EUKpv4ydb8INyyF/oTR8+gyOgutCd7CLUO8Bv1C1gR6cl1zbFwBriiMZ7g1zWJCjFOWrbfOXEDOR1FZ/16Pn4obUVVRkkJngqQlCKef5GVZvXTdTRd7tr6o5aBhooZKkbLzggAy/Ex1o+6wWT36oziCJQGk65mrZbvj2ABpeJsxh/FZDesCHXSYnnAeHsUZg9sD84MpC6hV7PROW2TOktWueUDxZ9XtsUFobdUF1nWT6TyTal2/VA6rvCZ+1L7/3caYJ+yHb5bqT//hOXIiHRt+ICo+nvovt99ubFtlgJ5sOf+TZgLl3TgB+oPS9xbf6l1hw7BJYyvD0fUiqoibM6nR7QtUCC7g+zVHYZhKsOeJYUpRFYiWTOTPkxMZ3zNbdhg27Iys3czMoWeF3LxWsIrKB8jAfJC7RE5cvnEF259bfwW4LpzJtL5DflhnRI/hBvgiAApTyJYr+qnfXfWoswTtsk4TeeZzccoYQhshbTXXYPq3YxZfPSu3GQrT9VnF6AjC6cTGH30n1SmqYj43V6RNzw78xbcmUuaEoxIfWgT4LXMEjQ5QMScFKpDctfqocIxQ1e6PYs9roUNIpKxqw+sHPblRVWMKAExBywgCPmGZXBkgo3EPjhBe0Rgz2bPIABuZ7ML9CH1dvyCt+OhzVDRN9P2Nww== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_04="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsHaeJCYJWEfuYw3Os2MJARG5KlbIuC/vXBkRQ8F8Ap4/WVKMmErDMzyxVXkIv7pcWPWwZFpEyVQhq/yIRce4KBu4ZHJy4+4tXLXLgYmufGfz7v8Ekx7yOD/G9kXB9+tq7xQj8uzl1mb606E3E0ZwCQIv/a6olaT/WQGe6RDpQAjCBlLTTT8JHKV0oUyjrEBrr0KO7SWZmAujFWDGk5s7vuDn5GOyHu61FFthOlmGMDVyjFTN9vYbSqVC0eyQDmKiUB84fIkXuyqQCnWZkWaCm3RctLukshJLjp/Hsix6im2cYHq1s4/pf0HnI+UEjgskr6vV0iz0B1cBjsYAMjT18nsnyiTyLIYaF+wuPbmAlFo606wfTGaB3jv64o99AIyv5/iPNW1q6p7JK8MbCF/O0Cyd9LOMt5Sccw6xMlQf6J85U/GFyGlsQfp4cu1cxpLo9bGebkAeVsv/I/aUYA9sOKjgJENzQ7dlsmMuoLrCelfPKCGfR6aN+yjZCkHusQddZkeK8eYOh3gVWtzqzc+SYtyW05wbFD1D7UBnqgaSca8wO+lTTMHP0Flf7MS0QeLXpV5WKlTEUoaFW1L5dFFGf6wgVzHTboeOEQhh51mJ+B5lQSGxg1x+00Rw2ZuB4AWlLjdNt5XD+2p41Ik1Xhhxw6aNDkwuHOqAwWpIR59K6Lw== ed.barberis+395719258032@cloud9.amazon.com"

# cloud9 public keys from appdynamics partner aws account for ed barberis. ["us-east-1", "us-east-2", "us-west-1", "us-west2"]
aws_cloud9_public_key_05="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLCTkBmyB5MvHe74RiCvQUoYHaL7e7wJbWEBoKZKXypUF0rkv020YOqbqZpaRG/66WyejCbatgLR1jYkRYl8VghzNnUZ7nSvK23hwGCyWDeYIpABlKAQNBBhOGpmC/rbk1UD4HqKRR7fB2d/SL6eswy4Mof/n84HP9czIgWZUL7EHH4ApzQnpl6jI8Cqnb4o/jR4SgcEsMeAJ/tLjuuI54Ijgwv1PAz68RlIuH2Pb9+nLc6JBkt8Fvv3F9KWFzTZCcPCIbl6GZpS0yQdnoYmoIbI5IAjGnrom1pz1T9KEJ8yOzuRQn19ptipJEXqUvgkq0G/1yjrAMdQIyH1y7sdR3BYlgaMA1mcR1mgD0O1NI1Wrkj+ws+65X7ccdVg0z+ohebBA5z2Di4AgxsxiwGbHlQcXTiQY64uYD+J3P7p4INIXMEBvtQfCFxvY72Kjs6qSUqCYi4pfzGhEDKHm4quDvseJyuLklbLIgXwesugUC1AxmugFYJ+yTvdXJ7lPn6bTkybUrV1ExLJEMP8/wnhbN1A94t9ZdT02untwc/rbh2NTX26F6fU3em/qhuewYZml9rdCtYc5iM4aNV3kRShUj6No9N4IE5VeREqJIs5TJpvaP9HPXQsB2cnk+EghxQtbuVyQmdijOI5BKoINTQXwB4AjzbmGDd5sGbHCaBS3NWw== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_06="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFQvNZ6BGtFRZphXhmuTNPChNqWyXl4KI9FNGbUfKQeYomWd40j6QJattQfbHkay8QvQTYHAxWqyP2J3WZe3mKGsQG8VGG3Dm8tyOraOyG7/0veNRt9B9fXSHKj+mrADO8jAC9at9dmBvnQIeNsrwQheljauzINVMqKelpy043amHFl1ipgI9i0LBVFaAI2+UFJZLoBGFSau8cJka583X6lJdqoAgAX7xoQMv4qbo3ZiYmCCcHLIe0zzC7HlkZ0zCHCDkoOTA/lPnIDrk3cWXVtDVII5xu9Kf0yMsc+Vx+nzPaKvEdlhGotszlQF68flY9oGjMIAP1mb18+I8LqJGb5AWqKomCQmKX9Mo2DxSxdbEtPYybkFB28gAOfvJBapfy0Nn8bKoM1Pnff5QGhtA9fITVAWmnot1SlgeHOqT4oVO+Bx48k+UkOhKQ4mynednQ6Zk0Km9+cZomRvpsSf5bHc5cy/wpu5I9Ieqs4gxDO7Vq/0Z9EPJyAR54v8BgyzyWj1JyeXifqdkDk0nL7MUB4XQGAUimBGegV+D1JVXk2FVz5AVgq37FBGuR5fBX8lqKBvu8tXW/vQk/08i7KohsVaunPzfBjQHk9ZW0iGW0DB9ydxgutuARTNN9udKTMGAvyEsUcKh77g0nOQdtUr67Hj5PPaSJ8llJV+i6A4S1vQ== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_07="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoy2S+6UkE3xLPOehCR7eXcqlG0djS/PsIRv+YYO+0MfKBfvVG4hZOhiVPfcyv0XcCSmk4H6NWGHEdfo8PrPs40nMwdZnBvarekK3580X7melF9zF8c/nA1PL4B8WbbFE96Ny30lm98Ji4ZbyCh0xgr1J68jcZuZIyoeqigKYH5lcpJoUWN6vG7jFCI/JEB975U9kGHDcIkSvLib2C26oszfkKw67UXCOdWeT8mEYm8hKrVPTXssjpM+8VxkMBQBZVZ+UOcwx8hCFx8wYeOV67CnJtegUySTsxVoUo1sK7Dw3QIEI9HqcTnqssF+C5neEHCmeYn5H8hmpFxnFipJBMtuCneHstJnd0qSuLS6eZe8rHRdQVQ+1sOnC2TplF+9s/7Tn9SlTB6K5jq1FLsegOyoxgDlOvX36f0q86MtqosW33Uxp47f5KtoXwaeV18N/fqeHV3o9sgq0DlCY4goxRUMN/4y2gLjzQREaZtsLZf7c5IZP7fuXWxicr2YBSsEmUsn9U7T/dCWSKZ1ijuu9hFVcApb6P8Afv15pHW0sL4xdvQNZaStP15CVNHHjfhJmNJAOrk8SPDhk4f2SZ++qLM9HZ2/CnduwlwlKLnV6YFXWgpycztWr34Kor885v4TqojWXuoqZv3D0JNaZ3+Y4UlmZlw4njlEjarROLC/Xk5w== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_08="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHYZJeASDhc0iR6yEO4obi6p5lOBzkauzOWfh33BedNA9mD2Foccb/m1dNlK9D247xMqIW6+wFRt3Njp+s6qyTG1kFCVlWVXw5KWe2GDdnTDZXQCuBWDglNRJItCdQAxOTo30ma4rUFciV5Zahyb1R4VbX7tjJVO80DY9bAxuCxrQf24TdeEcZAsdhzPjtk4pCvqfh27q3tm1B50EiXG2kPGOOlC4Vo2YNdAX2yQsQrhhABjetKqBc0zaef33AZiK8BdziHYRpSXvOkZ1/kKwl3q0tSWaoQXSz3J2WL52zx1WhbQ5sCOQ3fk/hoViLApPqVE/3qyyFTodcwn3vQ0C/XFnc/BgwyFCvGod2J/I8FhV9gSuE1jwC20X0djgvOMEhQx8Kw5L8qOhk0VkvTP+5j6dPD5EqhUedep0ImSg2i1/HsHaI6v10jVSFCzKTQKgHvG1M+3uRVPumOZ70eeiLxQHIo/E35p9FDG+XV2HO6DwrX+UvHS6BNPJW1ay5QOdDsFugZZCxyqsCi4YdoHTizefkExmzhNNh14+WwBuGBXHry6kBjpx+UzMe4Tu+Mx37axCL2joqo8UNDo7cqoKQ2UlsmRFVHRHUUbYXTmDVG7R+s/ETfmerqogP/KRqiiMECXFGd0kWhiVdeWpwxj4LC4dR8Ro8JTATW5aoOQ2HBw== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"

# 'grep' to see if the aws cloud9 public key is already present, if not, append to the file.
grep -qF "${aws_cloud9_public_key_01}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_01}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_02}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_02}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_03}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_03}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_04}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_04}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_05}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_05}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_06}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_06}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_07}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_07}}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_08}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_08}}" >> ${user_authorized_keys_file}

chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
