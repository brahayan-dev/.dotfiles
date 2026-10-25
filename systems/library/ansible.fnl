(local {: os-name : environment : run-string} (require :systems/library/common))

(local host-file :systems/hosts.ini)
(local config-file (if (= :Darwin os-name) :systems/life/ansible.cfg
                       :systems/linux/ansible.cfg))

(local playbooks {:life :systems/life/playbook.yml
                  :linux :systems/linux/playbook.yml})

(fn run-ansible [command]
  (run-string (.. "ANSIBLE_CONFIG=" config-file " " (table.concat command " "))))

(fn ping []
  (run-ansible [:ansible :-c :local :-m :ping :-i host-file :Workstation]))

(fn setup []
  (run-ansible [:ansible-playbook
                :-c
                :local
                :-i
                host-file
                :--vault-password-file
                :systems/.vault_
                :--become-password-file
                :systems/.become_
                (. playbooks environment)]))

{: setup : ping}
