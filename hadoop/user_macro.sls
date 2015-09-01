{% macro hadoop_user(username, uid) -%}
{%- set userhome='/home/'+username %}
{{ username }}:
  group.present:
    - gid: {{ uid }}
  user.present:
    - uid: {{ uid }}
    - gid: {{ uid }}
    - home: {{ userhome }}
    - shell: /bin/bash
    - groups: ['hadoop']
    - require:
      - group: {{ username }}
#  file.directory:
#    - user: {{ username }}
#    - group: hadoop
#    - names:
#      - /var/log/hadoop/{{ username }}
#      - /var/run/hadoop/{{ username }}
#      - /var/lib/hadoop/{{ username }}

{{ userhome }}/.ssh:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - mode: 744
    - require:
      - user: {{ username }}
      - group: {{ username }}

{{ username }}_private_key:
  file.copy:
    - source: /home/ubuntu/.ssh/id_rsa
    - name: {{ userhome }}/.ssh/id_rsa
    - user: {{ username }}
    - group: {{ username }}
    - mode: 600
    - require:
      - file: {{ userhome }}/.ssh

{{ userhome }}/.ssh/config:
  file.managed:
    - source: salt://hadoop/conf/ssh/ssh_config
    - user: {{ username }}
    - group: {{ username }}
    - mode: 644
    - require:
      - file: {{ userhome }}/.ssh

{{ userhome }}/.bashrc:
  file.append:
    - text:
      - export PATH=$PATH:/usr/lib/hadoop/bin:/usr/lib/hadoop/sbin

/etc/security/limits.d/99-{{username}}.conf:
  file.managed:
    - mode: 644
    - user: root
    - contents: |
        {{username}} soft nofile 65536
        {{username}} hard nofile 65536
        {{username}} soft nproc 65536
        {{username}} hard nproc 65536

{%- endmacro %}
