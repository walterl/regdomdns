casper = require('casper').create()
system = require 'system'

if system.args.length != 8
    casper.echo "Usage: #{system.args[3]} <username> <password> <hostname> <ip>"
    casper.exit()

username = system.args[4]
password = system.args[5]
host = system.args[6].split('.', 1)[0]
domain = system.args[6].slice 1 + host.length
ip = system.args[7]
ipfield = undefined

BASE_URL = 'https://www.registerdomain.co.za'
LOGIN_FORM_ACTION = BASE_URL + '/dologin.php'

findIpField = (hostname) ->
    elem = document.querySelector "input[value='#{hostname}']"
    elem.name.replace /\[name\]$/, ''

setField = (fieldname, value) ->
    inputs = document.querySelectorAll 'input[type="text"]'
    elem.value = value for elem in inputs when elem.name == fieldname
    document.querySelector('form').submit()


casper.start BASE_URL + "/clientarea.php", ->
    @echo "[*] Logging into RegisterDomain..."
    @fill "form[action='" + LOGIN_FORM_ACTION + "']", {username: username, password: password}, true

casper.then ->
    @echo '[*] Logged in'
    @open BASE_URL + "/clientarea.php?managedns=#{domain}"

casper.then ->
    @echo "[*] Loaded 'Manage DNS' page for #{domain}"
    ipfield = @evaluate findIpField, host

casper.then ->
    @echo "[*] Updating IP address of host #{host}.#{domain} to #{ip}"
    @evaluate setField, ipfield + "[value]", ip

casper.then ->
    @echo "[*] Logging out..."
    @open BASE_URL + '/logout.php'

casper.run ->
    @echo "[*] Done"
    casper.exit()
