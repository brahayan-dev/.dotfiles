(local common (require :systems.library.common))

(local host-file :systems/hosts.ini)
(local config-file (if (= :Darwin common.os-name) :systems/macos/ansible.cfg
                       :systems/linux/ansible.cfg))

(local playbook (case [common.os-name common.working-day?]
                  [:Linux _] :systems/linux/playbook.yml
                  [:Darwin true] :systems/work/playbook.yml
                  [:Darwin false] :systems/life/playbook.yml))

(fn run [command]
  (let [str-cmd (table.concat command " ")
        envar (.. :ANSIBLE_CONFIG= config-file " ")]
    (os.execute (.. envar str-cmd))))

(fn ping [{: environments}]
  (common.allowed-on environments
                     (run [:ansible
                           :-c
                           :local
                           :-m
                           :ping
                           :-i
                           host-file
                           :Workstation])))

(fn setup [{: environments}]
  (common.allowed-on environments
                     (run [:ansible-playbook
                           :-c
                           :local
                           :-i
                           host-file
                           :--vault-password-file
                           :systems/.vault_
                           :--become-password-file
                           :systems/.become_
                           playbook])))

{: setup : ping}
