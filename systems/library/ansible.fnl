(local {: os-name : environment} (require :systems.library.common))

(local host-file :systems/hosts.ini)
(local config-file (if (= :Darwin os-name) :systems/macos/ansible.cfg
                       :systems/linux/ansible.cfg))

(local playbook (case environment
                  :work :systems/work/playbook.yml
                  :life :systems/life/playbook.yml
                  :linux :systems/linux/playbook.yml))

(fn run [command]
  (let [str-cmd (table.concat command " ")
        envar (.. :ANSIBLE_CONFIG= config-file " ")]
    (os.execute (.. envar str-cmd))))

(fn ping []
  (run [:ansible :-c :local :-m :ping :-i host-file :Workstation]))

(fn setup []
  (run [:ansible-playbook
        :-c
        :local
        :-i
        host-file
        :--vault-password-file
        :systems/.vault_
        :--become-password-file
        :systems/.become_
        playbook]))

{: setup : ping}
