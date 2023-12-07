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

# cloud9 public keys from cisco run-on aws account for ed barberis. ["ap-northeast-1", "ap-southeast-1", "us-east-1", "us-east-2", "us-west-1", "us-west2"]
aws_cloud9_public_key_01="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNAixyFY3TtE80McCjGyU2uznRJriWyrMvqgNyvUTI9s6uyKTXvWBFkZv7ERZAZ2tRWyfztx/AYI4d58Nb7XB8DSTHTAJFD1pahdqg8JORTq6okoBz/3hCxZTlTcYETe9AFl9lfkpnf5MtGlDaNaWXAQt+ng3nO7uaSAzaPAf7c1nw7LSIOtidsAl4C73bg6UDBAdU/P9SX70GDPaJ6DqzEcIrcukT18i4+fEo0vsNBdjshNsFiNZjf+m1u+6UUPs9nUomWJ2M+wcS4/DfS/37LwOam/0gTRkzlB0wCkSSfi3iuKRRAKy6SQ2suRX5ZtcpL8JoNEWhiF0DOnpNVdcf2ZgyNQSootV6WJoURAMDgV5vchzLNMn1ByHwb6Y7VVS1/NFxk8NNKt3CdShM5VeNvUIbI4YsC7ldOCh3tqK8Add11HvMDvULOhzSnozULFh81TTk8+5Yx/ukg7nxm32qjDF7qUPBaZ7/N4IKKXoTq1lPDZ4oNoD0Tkoi12oOCdPcv139WVvhACgf5s9J7OWgYLC/22Q7ISTZIqCNeqmMHf9qRrWpyytLh1UF/YunQCUJb9OegmUbWhFRE0E3eRx/Tg5M/DY9RPsGddrEfkIxBAF/PTZAJZILWTwOkLvSQ38V81IOiMlBOjPaZ+Xavopy502o5U/O6xR85HUQo8pe7Q== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_02="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKSVbH8oNW8SpEk9YlEiwQyGxM09HPcn8YGfP7c9Zm30NwI+LGvl7S7Mpt7GahTUap7cQ7IOfvHORpNeU+HM18UFgyLlO+ojOePGltpChUTpoVFRhUhj83myoqSI5N8PyF/KfF6PKkve/dCDIyhC63guP8nDPlZ1NXpgRgkCaoktEcEerigmPNxdotcOySm69fZQMLRLXykGP+8RDZXVxI6mdsYm5VvQXkxEtqysuNBbPPdLpgkAYUKd/LwCNoJPHi3nXcFKpjBuxj+9xLWQ0/7ExHUyQzioSckqM0yHbzIvlc4OSX7Bq0WUNlWXUSdscqw7hASOjQTVQbHShWSeWE6VuHbTDfjf6Mrw73ydnAH7Bq5cGfmfpbiJDyATofVyoBpclDt/UK3VGkJG8xt2Y82GXUt2PucF7wjnC7t54COy1rWJsTEb+fXZtqyj/UTJiAuZlRRaN4tq5m+OuEzgF896mm0gRYav5Tt9p3yxUdPtfzuzEKuWiHHDFEqFaJLgPTKZFzjDTEZe7Psr5238VrgUd/WgU7fj3hsW7TA53FnIznBScOP6cXDA5kdlPTgMksfJhWZr7yWpnUEUaXK/U2INw/gxiVfhqi5JTUfVSu0B1Qbl256pegdnspLbdNFSOTdQ7vSK0p5oSVJt6e/ZTr0EKg/PnrS6DtrVfEh1qahQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_03="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWyfBLnIounVpDI1yWHAe2FSpCPisv8uFbQsja4NMjhAylDyaoKH0i0txpnMu/cJGigLf99Xyj8Va59A+DjrQ90rYiKpNZ9pDE6o5PET5Bo5LU1dJFLwho2DS+xd8MaAQ6+xIrBIkXYr+3otYTi+JgHGTjXl/3r90O/xUQG083udKo5XSLeonCmOYijS9rUGEly7BuCRfTS7JVPoZDyRjHNmyhdieNSEwwQMxLFgVmOPpDD0ayXXvSmNYzXHt5KVLmSDPoFUC2782Nr0ARTaIBhrQYZXWofZ89jzrU8AgTx+Aesp68p1K8hW2WH0+8ErbphEU35qIu18pdoNWI4bqjZNCeB3tOpnnCOkDAM4M5tPHNj6DiJqC+POlNBYYznx4TzDZ78TBuH9JMd2a8LpKXKgAkE6IOLqQjdcGYw1MTva/VRhxoF8kvSuesMADK2N4fRgFcETtbKN+7vCxWCtgsEHCIcxE22Tg0UZhDk1RIGFrrZyWA+PtUuQOaSkztOHZjdu254VZ3blKwtJXWcLnenmGpnn1rj7AkK/QliKZX1gzyAV/13mlWMJfRB2iCYZSj9zbI3RIpE1DFfub2Xa0CJytyx4u1bm6kw2cCutQrjFGXf8Mreg5iqICbBkPCnkd4hChdviVh8dIg/dUCGPZKNSOy55HKqDPPv/DYV9PCcw== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_04="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgdhOpq2NGMG7S57vOSLKLHsxHrb8XPjOPQ3ORytV6lIrCrcgQQbi/RmiX4qa1ibcMKzZ5EcphXmXJvX06Y3boijT3Yjx4SYwqQDeh46KMGML+1FnBo+oEzU6tiXHQSinwRssT7y7h/AXnZMOtnLo4buxDFggWF2407EkosGm/Du5916Bgzx39XVD0RFlQpUWmncM6M3z03bGjfud0HPTAe9998mZtyX8KCu4p5xYdtQ4NI0vlvnwqS8EMGZPutJQ//wauGtbV+6sanz4d4tXF5xtxyj3WaRbw5hiy4vlEwLjd38JZvwbYvPXWSPjoC03aEKaI7clTdq8xkjmVIwVpU1zzJ5YlFhl7qmwQUSgA1ZFdcwo5+TFbKzD9g7+Xww1knxAg12TN9z9Zz/FRmw+RJd6ZqsZ64PvCtAScaSOHqyjDCzyQQiNYZFuW5K5L2Ym7WPUKz+tBCRXR+8Lsx/MzchBcdydScvldI/yZbkVaU2R0hxL5MG65wwOVLhYAXUt3PA5KlajTTXFRBO2PhFhdjpYOS9OJnudpuPrQy1Bs+uoftid/ESb3M+JjD8wYwbp0KzXd9xjLFO4WoZho14a6bj/Ci8LijG2TIWunF45DrLBXxsnHawwdUr3426jRWxqxs2n8hAaZS/+mMjdNHTdgrSe8grPvhAXMg92r33brQQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_05="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgRDnonNF2G8Mp/ZxBI2yka6++IOiw4V6pCMtDGZd+KWQWOviMeFaPWeYeX09X1nlSn6BTLEnkEeT6zt+cKvxYzS634wsFaWxSMWeeL8MAR3aJZTkxTl5WLxlPxjQApT8d/64wicPnNJenAGJxRkaUZA5VGhlARQBVT2Xwmo30qPeWx2uiez5TOyk+p/hOdLPk+i/mtXfBWBtFIMgdtFltTD6bWk5Y64DelFfSooMaj1mAHZWTG3oxobHONvgbQhGxd1TLd6xSK5JUyC3ppE7rLFGzFr3F/5cahFk/dMdOAPKfadyPWdnBx5yukdXh+MLkSRHYqs0oNZaZDL81jFXBX5oVUpSWO/by8ZF1VvMXo8Gdbq9ct6ratvKkOz1nk29dMY/QEdnHqiZRL+cViF/p0IT3GMdPMZkG47gVKiW4WjT1/+PtPiohmTf29STMDQye0cUS4qHybLwasikdCKvznjnp0FGj4lK7XBcKX3OkLvyAfyGonBQEWFjw8EnefPmKZ/foSs/rU8Y5UqNXgatumPgxNcQekNLNB4B1RalX00AO1KuMR21flS+td28/pyPPNGt5U+TG5dU10YbHRtTrmH/ohXCbXomqF+J0OUw16teqo30m+YJFxRF3ccaDGXNvHqIyk74CbCySw6oZR3/qBe7xeWIOj5RvHiv9MVOJeQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_06="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrSp8xIbq7N3xtNInVNwPK6fJKtIWiyxjIllI4MjdPPZvQdRdOqGmK84K1gP6otYUqy2vIR1hUYoNcLL/EPCAFMwmc/ZWTfheVdSaCA7ninGthnzr9xTJyeqLHowH6zlywsbrLC2MfwaZzNtWOm358X2+Z4WEcmJHO+ny8Lq/4Yiou9YEiNA/FHDdZmMcHuZtUqdH6v5AGvI2D3WcGLpuIMadXOGNI3Pz3EZGAO7fRovlYEw7GMsAte6zdPF1CQWeUpXzrRHm+/3l+fQ/LDLA/u4EDUkYgOoBQcgMHrLwiyD0QumexoloDbvv4R+vzsizmSJAAOeNq0+8783VpbBeaUHjfG/0kd6HWYt2JCtZwzihYPoxqoIjBzQ5gbSSGuDW1a5kZXc81hkav1lG3d3PUKDWqg9cFfMOtCd8DMcKIMG0goQBgUYJJtuMV/sHlW3IH3zpxGt4+XldH8Ge08fe7tgMA4iprYO2caP8fciiCpSJfFgUXsNds41tQzPcwc8RAnoaPq+AsiVzVuyoydR4n4ma4n0hND9iW6XwRXa+ovfoxfg2HI9l0fvfHi+p680v63Cr5NFSZmijGi+Ln+zyzXywSbv8ixwI+8Eh3LAsenCzDKaRPDk8CbVL3BIft5dmAvz2kU1/uErMNK2lXOsSVLku/eo8m7maz7h4oizOX+Q== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_07="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtVexQEJUiF8ByVEM3tzENvrwV6LD8Wr8jI/zDXiari2rch3xOijHsjwRRDnD3JaYuT4y/IWSnirhvUfZmXxuJsrslKrX9KcAiaYHL8+rNRTiMKIj85ETb4zlHwdlO8sO/+30rqMpKxP05D3ciyoATda2cfOgaIlZG61vuypo7l6S649edumwK1xQSUn2e+DOZZBIpEQhvG10yEgKKbVGPwYBZJrCjXz1N1KCf6B7rLtZK7Fj0bTQ6eze7g4MdnQ93C+GaPcuUUhYqsJ5ZmPMUM+nFfs3OWMWJa+aUTPSiIlyOJ/P9+iABPBk0/Bjnf4RNwLTb6WSB8M8ffszSwKrYX63YIREocA9trEiI/cIxPnChPL5bBO1Lwqq1mCK9iTj/+25sk1kCfapsh06MlA6+TRjzL096sioKZhJ6IXzehgzuP5uqXpokRw5Ft0t3rBtsVGnxXnjOurJrw8HuqXwkD0syThROLEFDybgHrWyUG0mIU6RXWdBA8d5Ana0A+DgdgowuV+oKIagcB4JDypwzq0liJJ1U2d7q5FKfewXwX1QAOr1A3A38mlow1bieRo3dvmL/4eWI36q0gzy7FjN2cAz9LUoNHlU1B1dlefBfEZsxoGE8Q3sALPHAwSc1Bcq3CMOpWEHyTCDbu4f6NWijMHOUhArLJconhPATQ7Juxw== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_08="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD7oW7jK5eL3f9SnqLZvAD31OVdvyJ54/k8WJ/D6IjLAy0ZA0gE8Fqt6HTAfRnAACJohbMWsctMl9GSTA/mlxeklaoSWyktY9X7bGRmot9If5ReVLa+yV8dPlEHljaeMhloGy/WcZPHPBI+lYlDNjv5qbPeMWiRzucLGvyNbtW9KqXhFGegWGE3J7t+w2pyQbx8ZFgqiwfz6IX78Qofgd7sMcXGCB/h+hYWB3Ordwng2jIn32/azeQGO+dFHAkdMYjX37WayKWbGvcDE0Nl1CvM995GuT20K65iklmjzlkdfMoV5zUvMSOVYpDgot01sgTXr+2kTdObzOCyVPUCibuqseIaBL850KRYvgeJLdwSXVHTUDzRr1VnxnGSc+daQ2gULKznfuL0p05igV1189Fq6qC3UlQh7+DdMhGc+zSO6slUyHT5V27NueHFnXtwoyU3ePf8wzSkG32FbpQFV9Zx2iPhuSjHrzrSNLKaD1+wCIV2RgI4kyAOB9xngOVoGiZXBD+wYCYh1JWP8n10nbJdBINe4cS8rHpUG8T+KXYvdk3iesVzKbviFTSVhQGliqr5ywsIzGL4/Qek7AHa4U/dswa5vPcMXQeNQGhEWjU8ctdqpB5vOxtovDuERLMQHTQPcWuaaQq9LcEm9pO75N++I3EpNdw/dAeleimvKvAGvQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_09="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhwWQ4CGMpMhUdM+Dk/5Yq0/2pFlPPZ9U94/Eze0t4u7qQDsCVpAeUSD/KYuRk5aS98+uwhTBnDYCshAjsb+D8cvv0dDqNwqbMCdpPrOWICvyyTpcgxCYjrV6jQUrKFVKwgBXwmrl6dyOV07JDCAy+diXxrKQoFovw2TsAIOK1W4A5YjvlKhFYbpzgNYMx3ISc96ecwnkYB9h88n02afmfYIVFLGAOLbBhdUZECmvLy6VN6PTS55UB9UxHdq99owLB1NoXov0y9mgBHGjXnjbf/myFpJ20PP3SQ8rePI1B/ro2ry84WlXuuvegV0p7Xfp/NPlPKQ2qh2YezjZpp0Bug2YfHzdea2quj0tFBcw74oJ2IVxoPy4Sr/tAGyMfoSMQM57tSbVBeImQvnnbGq2LdnKlZfVUv4od7/Vh4SIc3Qgq25NIZTG/sgWaGNG6PTcZ6WEP3NHxFZuCjDA1zoiph6+t4LkICo8Smn4xnTTkS7KtSFtC2eDzBPW9/F6UnDFNaAKZzl5ju3hFrHubsHQ3PiNlLVHIur7i3ZqVuhK+V3PMTsV7Mwq+9JKqQnmoOHaLrZq44Ub520WCoSe14nH1/PJ+Ygu/+UBgkloOEAMo3mQEbHglRFFHt5sjKgi8KlALmkGEkfO5QPaObrkm7UuqEYBRE9CJfS4oDsEEMP25kQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_10="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWcJfIXL/kpsRY9W5kdXST7ZaFt+qwIDrAgidkswGCV1c3zcUCfZ+naoEKw5nQdibQho73HfJwHEqdHhjJp+5UL/m9uOzdYSVUWckobx+Jm2NG6ZiB3iDTLPX38oRJ+GBP1pLg+WWlCkeQV4vwDV++PNvrdcU64OuMT0dbHLo2+YHwApnhCoq2miGxmE8CjLQu4baYbriq3uatTJffChicXcYm24ik+q+Q2yC2Dea5bANl8byKugArMUDDEo51EAtxzo4kVaEHD2IDFZytMKklP7fG3EjqZSW915qw6FFTzYxp6w5ZC0vDVL2oyqRvMnlC+stVUH/RMOFyw1NAbsWz/rc8MS6N1nidrgVX3U36qmR6RZnDRC7kw37qTmvjcpzWWNoAlHrsllT5daFm6xzuVT4CGnMeqmGv1njItjr4SdawfHKrYX7FF9SIQbNDoITHo/XY3524WQopX6Se8naeIWGq1IGcKrOqkEfU3eXREii/z6sQRqt+nru0zohuhMiXHJtIDxjMmJtH/YGhYX78gp/dyP7/r+NkdyF20dOC+Ubfj1c+x1nGxK1ptIwB04jDHDlzuWdAKKs7QAbU36JAJmDmOg0rkofWGHy17Bh406s+aTQKQZSNmneN94PqnakIQWrPzrcNdPd4WFtqsKsBqylZAEDazE2nT1hAoKgyFw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_11="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQWDzTeyOOgJkE648K7niFKCvt2HfR1Aydi2S8g5pqFWzkjVVj8NgVz7Hn+V1Pyt0DCNS9RSkWkZ1qP0s1xr3itQy3QhKRsh5NwDoiXFHay5i0sDCfm+bphsg1RkSt55LZBK+nDmapurek5wQa0uLdDQnJf+0yZsgyE0Tz/D0cjF3KV+O/SDJ9DpvuSsH7dpzQ1klYkPrCKLa6mRmgKBf2mTsa3w65FJomChivBdkDWFG//Jtp7bjVI0zyKRUfq6eb6CJxtSLlVmALQn8w7RqMQ+Ol6KZXXxjOCo3vnHp4MFEkp1qXfUsgipKXoT3BY1AwfQ5x51moN4Z5BnLeKXBgD+ue4SRv0LNc14dl/LRcliIxXHpTd1C4S0q43nJaAZCMN0U/DGV6K2DS4zeCgLhCO+hgNjF/2MetMCIXikAQDsgy1beeYGXnoTOPM46G2LnDumLf9VyDar1Zb1ZWYAwXnIlqEppl0XVYb/Rk0PnSSaQX/EX8iT2gd1xOf1yRo3n+fJJu366la8oJEdVTYQdnA+fJBjzy/jVSe3na6pwr3Ogt6n3CM0gWL8UcwdyXllCIfs2S9axZQeaeK6wvd0OC4uwiyAkBV0w7ttmFMBLVwqZBiK6tg5RHBC/IjHoj1ihYnzdb3DASRPfaA0YKO3dXjQk8Pi1dn1Tif4d6tOAH/Q== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_12="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOCEHU0ygOHaI7u6F3AUFbjJuB6+urympwYHcwyWRArCse9ZIHdPltaNuUbxYvAWxwG+gSviy28BZlwDOOLCD3VEVexdDFpEh2qBzEf+OaVh9kwlNqBPoHaZL7cTbsRb5vlFWK/01jUgKnI2jathARN4/sn56neJ36KpfMfCwtOjpBYzjQ9nIVEC9m5ZAOdCtPdh+Lco1IgL2ug2qP9273oflSYw90sCw9znuYjowOsigAilhGlenLZYeql/s5QjGlffrke2w0z9Ux7Tr6EULDJHs1JgfLsLmk2kuOq3C9706CIjyQyecRfgPyHTVfPBzXjButJKHTFl6awc14MQuT0wF7DFe2wQGmhFG93FXNHg87BYnH88fWMpeUcI1Agr6GV46nmPJpR+h+adaZSDphe/3RUsSoiXENXZB4ASYAyK1xhFlQxgbk3s/JlLlht6l1HMvYbw/FFi9VlIbaAlJH3+qeOEgzsRzTm1S20VRgPxtQX+Hw3NTOGfxcwE9XyAPAndc6mPSJ7Vtg+36PauLZgQ5M8TEotpjtBDGXAjpAOz7k0S5nKVyrUD5+X14QLXTF9KmcdQx8fv1F1N6zMLT39cNJxpXskmwwovE4JcB2X/scx60Ae/R0ELC3e/r9R3L964yosTmrPWD70ken20pGJSG4FuZOk9wT3SDfGQxTqQ== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_13="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCauKkcd0elSHLJD2ViHuhKcROo5yvFuvmIcsyvFJSi930w8LdIYaqgq5MGhDkQl5ZBBQvDRJNyq1UsvjPPNd/C5PPlQw1kxYv2MSyVClvlxB86ndRFV5pCkMzuff7sI/rDlI5Za4UeLim2BMYswc7mt2wxsJDyPJFazlU1W+D/zCSG+Yb6SYu5YXU4CSdAUTrbhYkACad8FdJDJHrlAscZJ4XAgnm+kFXhjKsUkOKksjiJQPNMg5f1eQfrBySxWtiU9J6Jbd+w89zNuTMuLcZDEU3G+1uq3RMerezvuL6ZZ6aTddlNT4jmBWYSpz040g/sscV+SctXORBRexjGQF4b9AZOlGmCB4eRvpNhtnsgjNbY1l8RrQDV9IJyJc+Ys9YO+EhpjoMmHvkmMeUiQMkh3SPimribaA2TJ4U4p8R2W5WQSOksAz3AXE7EZRSRY9+CfSRzv3ywgJafnXCY2GwLWYPeYku5Jko0JKT991pxNTctU0NChcjhI/UFviuZNIZsG8IP44RBwd4k0CXbxVeKpzJLSzxaNQsNkdgn/QeL0lEXDBIXWAO1U/dYL5BMl0HLx/Vjc1Vh041+roBHiP5E3IgMNLKBZHmfMtDXkgv7NL4zi/4Om0v+QSOPns5JQIAWQ92HmooCHq0rIg29sItN4+4q6Xc7GV3nHYcoNTtBnw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_14="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXAgvFPH5MJa0P2EUKpv4ydb8INyyF/oTR8+gyOgutCd7CLUO8Bv1C1gR6cl1zbFwBriiMZ7g1zWJCjFOWrbfOXEDOR1FZ/16Pn4obUVVRkkJngqQlCKef5GVZvXTdTRd7tr6o5aBhooZKkbLzggAy/Ex1o+6wWT36oziCJQGk65mrZbvj2ABpeJsxh/FZDesCHXSYnnAeHsUZg9sD84MpC6hV7PROW2TOktWueUDxZ9XtsUFobdUF1nWT6TyTal2/VA6rvCZ+1L7/3caYJ+yHb5bqT//hOXIiHRt+ICo+nvovt99ubFtlgJ5sOf+TZgLl3TgB+oPS9xbf6l1hw7BJYyvD0fUiqoibM6nR7QtUCC7g+zVHYZhKsOeJYUpRFYiWTOTPkxMZ3zNbdhg27Iys3czMoWeF3LxWsIrKB8jAfJC7RE5cvnEF259bfwW4LpzJtL5DflhnRI/hBvgiAApTyJYr+qnfXfWoswTtsk4TeeZzccoYQhshbTXXYPq3YxZfPSu3GQrT9VnF6AjC6cTGH30n1SmqYj43V6RNzw78xbcmUuaEoxIfWgT4LXMEjQ5QMScFKpDctfqocIxQ1e6PYs9roUNIpKxqw+sHPblRVWMKAExBywgCPmGZXBkgo3EPjhBe0Rgz2bPIABuZ7ML9CH1dvyCt+OhzVDRN9P2Nww== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_15="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsHaeJCYJWEfuYw3Os2MJARG5KlbIuC/vXBkRQ8F8Ap4/WVKMmErDMzyxVXkIv7pcWPWwZFpEyVQhq/yIRce4KBu4ZHJy4+4tXLXLgYmufGfz7v8Ekx7yOD/G9kXB9+tq7xQj8uzl1mb606E3E0ZwCQIv/a6olaT/WQGe6RDpQAjCBlLTTT8JHKV0oUyjrEBrr0KO7SWZmAujFWDGk5s7vuDn5GOyHu61FFthOlmGMDVyjFTN9vYbSqVC0eyQDmKiUB84fIkXuyqQCnWZkWaCm3RctLukshJLjp/Hsix6im2cYHq1s4/pf0HnI+UEjgskr6vV0iz0B1cBjsYAMjT18nsnyiTyLIYaF+wuPbmAlFo606wfTGaB3jv64o99AIyv5/iPNW1q6p7JK8MbCF/O0Cyd9LOMt5Sccw6xMlQf6J85U/GFyGlsQfp4cu1cxpLo9bGebkAeVsv/I/aUYA9sOKjgJENzQ7dlsmMuoLrCelfPKCGfR6aN+yjZCkHusQddZkeK8eYOh3gVWtzqzc+SYtyW05wbFD1D7UBnqgaSca8wO+lTTMHP0Flf7MS0QeLXpV5WKlTEUoaFW1L5dFFGf6wgVzHTboeOEQhh51mJ+B5lQSGxg1x+00Rw2ZuB4AWlLjdNt5XD+2p41Ik1Xhhxw6aNDkwuHOqAwWpIR59K6Lw== ed.barberis+395719258032@cloud9.amazon.com"

# cloud9 public keys from cisco run-on aws account for james schneider. ["ap-northeast-1", "ap-southeast-1", "us-east-1", "us-east-2", "us-west-1", "us-west2"]
aws_cloud9_public_key_16="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnCzCj6h0EF9AVL6JjDnIXC1p9+QuJlkTLGLLLeMbCwio6mG+0RzIxHU9L2sGLbJJu58L35eao7djthu09+gbsyGJEY/7zLADeLQgi5GuLVZtiYT4ipQk2YbDKYwzjPXcMgsiL+yz18Ff/08FRMj+fEe1flJ/53rvS42o75gP9js0HSn0PGt7dln0f9UY/0VF+QwYgRPld/R5YIqTHLK1CpQqdC3tcVb1CkGZHaK3lqB/BxC4I/F6nqrwwWlwo3D21lSSjpb0Knn64H86V+PlNbDaOTRU0bO4lUBtQXbC8J2t0+3JzX2pyDSyWLCprnTRXRjxdT70GQI4x5FNwrsFHpmZ7tbHdLtNnHq5KdEQdwoSLN4tgSbrzxu39rBWMrYfx0lHOweLanhK5HHIb4z7K2NSSmNHkc+Th+Fj0dQdaYLJOs7CKpccde4FR1mpcj7aabzoaYBzYpT6oHzo6OwXOoAw37HSdpLk03S7bfuydsvz1OPm2VzEtpBETwbZEHD03Gh0AyzfhVVpU/u3JfirR2qcZ7LveRDngAyZA1BCFM5Z4JbL6JC0PlUtf47rygRpmcR1/kX53455I3/uqPnzBLPZhei93y/mZqd1YUnRXBsvkHmSDMVPC9XT9V25sfYEkVa9FX28mD5bGy8X+a2EpfkJyNdsiVD4jKlK9oLL0Zw== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_17="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2KgKwcZQpp1MTCT2kXoNAOdmtCieVFdVQ1ktCyGZgT5LhJnoIRT+sNfja0N5mtPEDM5TV9/NNDA00y6svdhgHvv1JwEdTokUaYzHxcleH+KVLgq8SuFxDosiT4HJCIJuXxM6JlZ/RtSGqt5RQEfmqhf5mR457SVrCwAZMJmV52Wq5XSFOBMPmsoqyRTpbDhHcDobxOspJIxQoOXzBJFINOWpiluW60tjihIrCpEa0gY4jN03CYT17ovmuiifOTQwT/2hdqxTARi8h1zZjzKWeuC+rBozpOpujudpR8Na6tmg0N88IlTDQ0txCJh9VYtljrnq+lLaMWq5Fixn1hvSDCEPX6EqlGbC0O/q4vMPZJyymJKHTxZjdaizLOboYZZYG5mbsTLLAGbyiqkwyvyZ6pscHmz6CmXkY54k3hyDwec38taxbpPMvu/O1cklGOgka/mJkfBmPIz+NhBt3lAUS9pjNMAdTWnTSV3UuW0+0bIJzuWpeKIXdlBOEIHnui+zSAMq8QanueJ2li1nJo1O2zZMqK1ye02nZB5fzO7NMiQWOzAmm+u2bNyDttZjR7c2osUbNWFXtTjp/Y/E5P2HTnB5nX15Em/uTzSdv0JrVr0CwVLI+1jJfPPf66X0UYPws/XD67sY1SMJqW2YcYcvelG51Z5U/MOHS8+kgb0BRZw== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_18="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfRw2ymhlU0vi7Byhy9H1I7BvzjG0Jtf/fKo1yhnU1Bwmj0eBIAMAbkSVEbWN8xKPU1g9ibb6Lr2WN6KGfzCeaWQkYAmSelnKQZ9rp8D4uvHijcoT3Tu0Nbz715766YP/VZfampyryyVhnsprxK/4indyv8L1XeMldhUceaCZpz4dgCwSZ3Aal8GSGWJe51woG/6MSGJgoX2dFFJJkH7+no29lL93ll7Ct95TDSdR4YXJ8ApOeUHS2+h9dcxOwlQqN4rlB9p15sx3CDIis+61E2WB4NuP/OR9HTPoMUKP4H8liEFdK0Muz1vA5uoeNmMO4loU31bDyFgu8zTQFNsS9dpWoGdfiakgEh5/Qe/HmbxHmr5iXeDbw30dgSuOFy399gv55kYnj+iWUudKDf5Y8yDapoCTh5pRLDzLQjjpZLYvHK5ltZh594SSZDaumzAzJiVML7k+5pjkE9YugM+tgv8nkBwEGA4rJLXN0gL8aN/BcG7ZafzZtyerj6zQWgyEmW9az9pfKcqtEh17zje1S1WJAtUJG9mUK1OTNX+JByNaqMGsbsMLoElDDRTOhhZsaQsCsOta1GgdrhoemrS2tfQwyDByCZsB9Ib73Tzd4Gbz1FNN/g7RAKLbWz69HPqoORvUQQeXlGaGL7csX0UDGYPly2jC9lV68ao2DNUCTMQ== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_19="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnA5IwRyA5ZIVYzlSe/aNfGAqMMWAC5HBkwvC+Ci6H2fNfaZ17ftb0KTOYMOZ4SYEYz4/xRJK5AbJn9/asxd60DWYqE7HYonPW/4XX3caUteslxRpSAP9pAai2qZDaJUpy+Stey/31zbYMyCb0xq3vSfP3nNiNCS/IGvCRFZyNQuIZ8SlGyhLAYRpPWvn3yw6pAdBJXxiDMEF0t6H1G8jZDtGhWka9tRcHU596luZQb4XDNwkrw3FmZTOJxzetcJgiRxiG5oRfs1G4xgogFEXMQhmfrEg7BlxqzZhRCDsmUDJFYbL3C5jvSPztcOXn/XwEJ14x4D7rsSoAdPBhgzF+iPtjEUpBlqEa+J+Fpdr2m6JDdoRMgEP/2jBpjvqfwJNSRooXPgw/Gfkja+9/S4IWfNI5n8MC1iZwa7rzGjZn2lwtC32oq3WTkf2IfSm5WAG9bsG+15U4RM6oKAhPzalByOJsT9H+S37LK/62PT9X/xEO/pF/2JKY1qpVPvDvC6fyU9Es6RgFYrRPuQ8fEu9vaK++aK2tc/X9jhzVuxxBJqV1tOlKVjjSKIE8DlRR3WFYbJOTdeScCCtfrC0Kx6D3nn3T4TL+aHkpM/vfBqGk5dOZRVCUn8YQx1Ilyqqm0+OiHeaoKSwXSUVh/zZw6Ls501pbxShlJiKhsgPNu65Cnw== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_20="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtrCQdSgE2Ct8Rufb2i5g7NVkG1Ynq4QW/x76L/ESJBreBdoWdE1v/y0xgaeXTPx3W0CZXnkVvoQIycHmNsUHvtaLaPAoWYEkPNxa9/6iM50ngZl3aFDImNLdial7f4j6yrgu+uGHDgWwCt0FKV0AItgDLW0xJAcYpa7at3eiBCGAYv00r6HqpEZTUYZ8np+3XTMAjb3Wx5erJ8ab1BqiJudoXmhBUHhYK4qtLulB9mOSRAfs4yP8Lg07a22fXqDXDsAOUACN5gWNct+uRO0zHy0/1AyiairJvlne0jgnKu8JXSztXms4be6QMFSlLi1heygNIHTXq3+IUOUkdea2tsdbX1UghGios7DLQ0nNJGBEW1qD7b2Q7yejl8avru7zYYVLlRWjlPggmGG5wup1PNxh5Ecctk9PRLTgXmjuq6rjmDMfW+ng0HHaQKUXjZ83kOQg1x/QSv2jmu8g8ixhBkTkb6oIZxKLwlG7nEJ+qzDPCHVfDZ/gWO9+C0jU0+Q6YLZiWBXKTdYOLhOrqhM1xoElcuHnhJRpCBSaIZoSK49yDdVUva2ZLZWWqFZZbr9gaixiyPc7Yu9K+KfuPN4mEvKgWbpwlUo2DNoRUSeS7RophfCC7lZ70NWk2iE2eX8X1qVYEKiRa80nHTM2SVOPJZzxaEsuEIkX815p8XU+bBw== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_21="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYcOBIopBIWr0/uq9FPu/isleyX+NaSDFUfPJLgHUfrrb62/li9tTRFhVYBLFsT+8e0p/qlgdCSjDyMG5N0DUpAxEUCm89YvofzoMd2QDsNkVyv5mBpX2Lh/rdA0r9mg8zwRUX3xc4f2SbDasiICbb4R42lhkArOAetARUVe3v3SuyopuEr9UUfv77xYJjQiBpsV2ms74bqMWu63xFBsOxRqgqFYipL6FBJFD8QurORvBDF5OFNxP955itbnB7Z4TJ4MZ7wVMQjkBC/rfZrKB8um4cGVGFMpZD+3mReJLQplVFIctI9enJPQ+8mYsYTva/cSpA3mNzGuSk2t80HBQ1FVOXwckkKNw2AHvDib/vhOFXlVuc5bD6Eni0wq0tZmQH8AM0ujdD38BxAGtIcQTUJPMInh4vXOGLi9l3O9m8RIqj8hNgE5OGC2VpA/tnJbFBgqvSy0QTeY/0VQ5IDHr8aKirmbJ4CpV0VFFL/tEr9g3RcDb/ksDYw84o9gG6iAHZpGl0QhTeHZn1TjlSxwcmW+LZ6pJrIf0aSDBDzhfgfJsQPKegn1e42j7e50nFkVzMMr9zcm87zyD4cwknIlAk85Uh5T8+jV8kd/+KaRZFKVVhoANpQBPbpfZdkkzMxkNshFV3tLMdrdpHbYfsE2Qt97UN/XFoJbqwf29tVkhefQ== james.schneider+395719258032@cloud9.amazon.com"

# cloud9 public keys from appdynamics partner aws account for ed barberis. ["us-east-1", "us-east-2", "us-west-1", "us-west2"]
aws_cloud9_public_key_22="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLCTkBmyB5MvHe74RiCvQUoYHaL7e7wJbWEBoKZKXypUF0rkv020YOqbqZpaRG/66WyejCbatgLR1jYkRYl8VghzNnUZ7nSvK23hwGCyWDeYIpABlKAQNBBhOGpmC/rbk1UD4HqKRR7fB2d/SL6eswy4Mof/n84HP9czIgWZUL7EHH4ApzQnpl6jI8Cqnb4o/jR4SgcEsMeAJ/tLjuuI54Ijgwv1PAz68RlIuH2Pb9+nLc6JBkt8Fvv3F9KWFzTZCcPCIbl6GZpS0yQdnoYmoIbI5IAjGnrom1pz1T9KEJ8yOzuRQn19ptipJEXqUvgkq0G/1yjrAMdQIyH1y7sdR3BYlgaMA1mcR1mgD0O1NI1Wrkj+ws+65X7ccdVg0z+ohebBA5z2Di4AgxsxiwGbHlQcXTiQY64uYD+J3P7p4INIXMEBvtQfCFxvY72Kjs6qSUqCYi4pfzGhEDKHm4quDvseJyuLklbLIgXwesugUC1AxmugFYJ+yTvdXJ7lPn6bTkybUrV1ExLJEMP8/wnhbN1A94t9ZdT02untwc/rbh2NTX26F6fU3em/qhuewYZml9rdCtYc5iM4aNV3kRShUj6No9N4IE5VeREqJIs5TJpvaP9HPXQsB2cnk+EghxQtbuVyQmdijOI5BKoINTQXwB4AjzbmGDd5sGbHCaBS3NWw== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_23="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFQvNZ6BGtFRZphXhmuTNPChNqWyXl4KI9FNGbUfKQeYomWd40j6QJattQfbHkay8QvQTYHAxWqyP2J3WZe3mKGsQG8VGG3Dm8tyOraOyG7/0veNRt9B9fXSHKj+mrADO8jAC9at9dmBvnQIeNsrwQheljauzINVMqKelpy043amHFl1ipgI9i0LBVFaAI2+UFJZLoBGFSau8cJka583X6lJdqoAgAX7xoQMv4qbo3ZiYmCCcHLIe0zzC7HlkZ0zCHCDkoOTA/lPnIDrk3cWXVtDVII5xu9Kf0yMsc+Vx+nzPaKvEdlhGotszlQF68flY9oGjMIAP1mb18+I8LqJGb5AWqKomCQmKX9Mo2DxSxdbEtPYybkFB28gAOfvJBapfy0Nn8bKoM1Pnff5QGhtA9fITVAWmnot1SlgeHOqT4oVO+Bx48k+UkOhKQ4mynednQ6Zk0Km9+cZomRvpsSf5bHc5cy/wpu5I9Ieqs4gxDO7Vq/0Z9EPJyAR54v8BgyzyWj1JyeXifqdkDk0nL7MUB4XQGAUimBGegV+D1JVXk2FVz5AVgq37FBGuR5fBX8lqKBvu8tXW/vQk/08i7KohsVaunPzfBjQHk9ZW0iGW0DB9ydxgutuARTNN9udKTMGAvyEsUcKh77g0nOQdtUr67Hj5PPaSJ8llJV+i6A4S1vQ== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_24="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoy2S+6UkE3xLPOehCR7eXcqlG0djS/PsIRv+YYO+0MfKBfvVG4hZOhiVPfcyv0XcCSmk4H6NWGHEdfo8PrPs40nMwdZnBvarekK3580X7melF9zF8c/nA1PL4B8WbbFE96Ny30lm98Ji4ZbyCh0xgr1J68jcZuZIyoeqigKYH5lcpJoUWN6vG7jFCI/JEB975U9kGHDcIkSvLib2C26oszfkKw67UXCOdWeT8mEYm8hKrVPTXssjpM+8VxkMBQBZVZ+UOcwx8hCFx8wYeOV67CnJtegUySTsxVoUo1sK7Dw3QIEI9HqcTnqssF+C5neEHCmeYn5H8hmpFxnFipJBMtuCneHstJnd0qSuLS6eZe8rHRdQVQ+1sOnC2TplF+9s/7Tn9SlTB6K5jq1FLsegOyoxgDlOvX36f0q86MtqosW33Uxp47f5KtoXwaeV18N/fqeHV3o9sgq0DlCY4goxRUMN/4y2gLjzQREaZtsLZf7c5IZP7fuXWxicr2YBSsEmUsn9U7T/dCWSKZ1ijuu9hFVcApb6P8Afv15pHW0sL4xdvQNZaStP15CVNHHjfhJmNJAOrk8SPDhk4f2SZ++qLM9HZ2/CnduwlwlKLnV6YFXWgpycztWr34Kor885v4TqojWXuoqZv3D0JNaZ3+Y4UlmZlw4njlEjarROLC/Xk5w== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_25="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHYZJeASDhc0iR6yEO4obi6p5lOBzkauzOWfh33BedNA9mD2Foccb/m1dNlK9D247xMqIW6+wFRt3Njp+s6qyTG1kFCVlWVXw5KWe2GDdnTDZXQCuBWDglNRJItCdQAxOTo30ma4rUFciV5Zahyb1R4VbX7tjJVO80DY9bAxuCxrQf24TdeEcZAsdhzPjtk4pCvqfh27q3tm1B50EiXG2kPGOOlC4Vo2YNdAX2yQsQrhhABjetKqBc0zaef33AZiK8BdziHYRpSXvOkZ1/kKwl3q0tSWaoQXSz3J2WL52zx1WhbQ5sCOQ3fk/hoViLApPqVE/3qyyFTodcwn3vQ0C/XFnc/BgwyFCvGod2J/I8FhV9gSuE1jwC20X0djgvOMEhQx8Kw5L8qOhk0VkvTP+5j6dPD5EqhUedep0ImSg2i1/HsHaI6v10jVSFCzKTQKgHvG1M+3uRVPumOZ70eeiLxQHIo/E35p9FDG+XV2HO6DwrX+UvHS6BNPJW1ay5QOdDsFugZZCxyqsCi4YdoHTizefkExmzhNNh14+WwBuGBXHry6kBjpx+UzMe4Tu+Mx37axCL2joqo8UNDo7cqoKQ2UlsmRFVHRHUUbYXTmDVG7R+s/ETfmerqogP/KRqiiMECXFGd0kWhiVdeWpwxj4LC4dR8Ro8JTATW5aoOQ2HBw== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"

# 'grep' to see if the aws cloud9 public key is already present, if not, append to the file.
grep -qF "${aws_cloud9_public_key_01}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_01}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_02}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_02}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_03}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_03}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_04}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_04}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_05}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_05}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_06}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_06}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_07}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_07}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_08}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_08}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_09}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_09}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_10}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_10}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_11}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_11}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_12}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_12}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_13}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_13}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_14}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_14}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_15}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_15}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_16}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_17}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_18}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_19}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_20}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_21}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_22}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_23}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_24}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_25}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_16}" >> ${user_authorized_keys_file}

chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
