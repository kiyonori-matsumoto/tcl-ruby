[![Code Climate](https://codeclimate.com/github/kiyonori-matsumoto/tcl-ruby/badges/gpa.svg)](https://codeclimate.com/github/kiyonori-matsumoto/tcl-ruby)
# tcl-ruby
Tcl interpreter for Ruby

## How to use
- Instanciate TclField
```
set f = TclField.new
```
- Parse commands you want to
```
f.parse('llength {A B C D}')
=> 4
```
- You can get variables with TclField#variables
```
f.parse('set A 123')
f.variables('A')
=> '123'
```
