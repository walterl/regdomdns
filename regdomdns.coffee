casper = require('casper').create viewportSize: { width: 1280, height: 720 }
args = require('system').args

if args.length != 8
  casper.echo "Usage: #{args[3]} <username> <password> <hostname> <ip>"
  casper.exit()

username = args[4]
password = args[5]
host = args[6].split('.', 1)[0]
domain = args[6].slice 1 + host.length
ip = args[7]

DEBUG = false
BASE_URL = 'https://www.registerdomain.co.za'
LOGIN_FORM_ACTION = "#{BASE_URL}/dologin.php"


casper.start "#{BASE_URL}/clientarea.php", ->
  @echo "[*] Logging into RegisterDomain..." if DEBUG
  @fill "form[action='#{LOGIN_FORM_ACTION}']",
    {username: username, password: password},
    true

casper.then ->
  @echo "[*] Logged in as #{username}" if DEBUG

casper.thenOpen "#{BASE_URL}/index.php?m=DNSManager2"

casper.thenClick "a[href*='#{domain}'] + .list-actions
  a[data-original-title='Edit Zone']"

casper.then ->
  elName = @evaluate (hostname) ->
    hostEl = document.querySelector "input[value^='#{hostname}.']"
    recEl = hostEl.parentElement.parentElement
    recEl.querySelector('td[data-label="RDATA"] input').name
  , host
  @sendKeys "input[name='#{elName}']", ip, reset: true

  if DEBUG
    @capture 'filledin.png'

casper.thenClick 'button[data-act="editZoneSave"]', ->
  @capture 'buttonclicked.png' if DEBUG
  @echo "[*] Updating IP address of host #{host}.#{domain} to #{ip}"

casper.waitForSelector '#MGAlerts > div[data-time] .alert', ->
  @capture 'changessaved.png' if DEBUG
  newIp = @evaluate (hostname) ->
    hostEl = document.querySelector "input[value^='#{hostname}.']"
    recEl = hostEl.parentElement.parentElement
    rdataEl = recEl.querySelector 'td[data-label="RDATA"] input'
    rdataEl.value
  , host
  msg = @evaluate ->
    alertEl = document.querySelector '#MGAlerts > div[data-time] .alert'
    successIdx = alertEl.getAttribute('class').indexOf 'success', 0
    alertType = if successIdx >= 0 then 'success' else 'error'
    alertMsg = alertEl.querySelector('strong').textContent
    "#{alertMsg} [#{alertType}]"
  @echo "[*] Response: #{msg}"
  @echo "    New IP: #{newIp}"
, null, 60000

casper.thenOpen "#{BASE_URL}/logout.php", ->
  @echo "[*] Logged out..." if DEBUG

casper.run ->
  @echo "[*] Done"
  @exit()
