<!--- 
Copyright 2018 Software AG

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->
# <a id="intro"></a>Lambdas [![Build Status](https://travis-ci.org/SoftwareAG/apama-lambdas.svg?branch=master)](https://travis-ci.org/SoftwareAG/apama-lambdas)
This is a library that adds lambdas to [Apama](http://www.apamacommunity.com/).

Lambdas in EPL (Apama's programming language) are closely based on Arrow Functions in JavaScript. They are inline actions that manipulate one or more provided values, implicitly returning the result.
```javascript
action<any> returns any multiplyBy10:= Lambda.function1("x => x * 10");

multiplyBy10(1.5) = <any> 15.0;
```

This library is particularly useful with [RxEPL](https://github.com/SoftwareAG/apama-rxepl) (A functional programming library, similar to streams)

## Contents
* [Installation](#install)
* [When to Use Lambdas?](#usage)
* [Different Types of Lambdas](#lambda-types) 
* [Language Features](#language) 

## <a id="install"></a>Installation

First head over to the [Release Area](https://github.com/SoftwareAG/apama-lambdas/releases) and download the latest release.

The deployment script (Inside the release) provides a way to make Lambdas for EPL globally available to all SoftwareAG Designer workspaces.
### 1. Installing into Designer
1. Place the Lambdas folder somewhere safe (somewhere not likely to be moved or deleted)
2. Run the deploy.bat
3. Follow the instructions
4. Restart any running instances of SoftwareAG Designer

### 2. Adding to a Project
1. From SoftwareAG Designer right click on your project in `Project Explorer`
2. Select `Apama` from the drop down menu;
3. Select `Add Bundle`
4. Scroll down to `LAMBDAS_HOME/bundles` and select `Lambdas for EPL`
5. Click `Ok`

When run via Designer, it will automatically inject all of the dependencies.

### 3. Packaging a project (For use outside Designer)
The Apama tool `engine_deploy` packages a project so that it can be run outside of designer.
1. Start an Apama Command Prompt (Start menu, Software AG, Tools, Apama, Apama Command Prompt)
2. `cd` to your project directory
3. Run `engine_deploy --outputDeployDir output.zip . <rx_epl_install_dir>/lambdas.properties`.
You'll end up with a zip of your entire project.
4. Unzip it on whichever machine you'd like to use the project.
5. Run `correlator --config initialization.yaml --config initialization.properties` from within the unzipped directory to run the project.

## <a id="usage"></a>When to Use Lambdas?
Ever find yourself writing this:
```javascript
aFunctionThatTakesACallback(callback);
... 
// Much further down
...
action callback(float arg1, float arg2) {
	// A simple callback
	return arg1 + arg2 + 30.0;
}
```
You can simplify the code by doing this:
```javascript
aFunctionThatTakesACallback(Lambda.function2("arg1, arg2 => arg1 + arg2 + 30"));
```
This is particularly useful when used with functional programming (Eg. [RxEPL](https://github.com/SoftwareAG/apama-rxepl))
```javascript
Observable.fromValues([1,2,3,4,5])
	.filter(Lambda.predicate("x => x % 2 = 0"))
	.map(Lambda.function1("x => x * 30"))
	.reduce(Lamda.function2("sum, x => sum + x"))
	.subscribe(Subscriber.create().onNext(printValue));
```

## <a id="lambda-types"></a>Different Type of Lambdas
**Functions** - Take a varying number of arguments and return a value  
```javascript
action<> returns any ex0 := Lambda.function0("10 + 5 / 2 + ' = 12.5'");
action<any> returns any ex1 := Lambda.function1("x => x * 10");
action<any, any> returns any ex2 := Lambda.function2("x, y => x + y");
action<sequence<any> > returns any ex3 := Lambda.function("x, y, z => x + y / z");
```
**Predicate** - Take a single argument and returns a boolean  
```javascript
action<any> returns boolean ex := Lambda.predicate("x => x >= 10 and x < 20");
```
**Call (Awaiting Apama 10.2)** - Run a lambda just for side-effects (Not yet possible)
```javascript
action<any> ex := Lambda.call("x => x.doSomething(10 + 3)");
```
## <a id="language"></a>Language Features
Lambdas attempt to provide a language very close to EPL but without the need for casting. You will never have to write  `<sequence<float, boolean> >` within a lambda!

**Numbers**
All numbers are treated the same and can be operated on without conversion. 
```javascript
Lambda.function1("x => x + 10 + 11.1 + 22.2d")(1.1) = <any> 44.4
```
This follows the rules of [coercion](#coercion).

**Strings**
Strings can be defined with either `\"` or `'`. Generally `'` is easier because there is no need for the backslash escape character.
```javascript
Lambda.function1("x => \"hello\" + 'world'")
```

**Brackets**
The usual bracketing syntax applies
```javascript
Lambda.function1("x => (x + 5) / 12")
```

**Numeric Operators**
All of the usual epl operators (`%`, `/`, `*`, `-`, `+`).
_Note: Type [coercion](#coercion) may happen._

**Logical Operators**
All of the usual epl operators (`=`, `!=`, `>=`, `>`, `<=`, `<`, `and`, `xor`, `or`,`not`). 
_Note: Type [coercion](#coercion) may happen._

Some non-epl operators:
`!` - Same as `not`

**Ternary Operator**
```javascript
Lambda.function1("x => x > 10 ? 'Big' : 'Small'")
```

**Field, Dictionary, and Sequence Access**
```javascript
Lambda.function1("event0 => event0.fieldName")
// or
Lambda.function1("event0 => event0['fieldName']")
```
```javascript
Lambda.function1("dict => dict[key]")
// or (If the dictionary has string keys)
Lambda.function1("dict => dict.key")
```
```javascript
Lambda.function1("seq0 => seq0[0]")
```
**Special Values**
`currentTime` - The same as in EPL - Gets the current time in seconds (usually rounded to nearest 100ms) 

**Event Construction**
Events can be constructed in the standard epl form:
```javascript
Lambda.function1("x => com.example.MyFirstEvent(x, x)")
```
Event names **must be fully qualified** (regardless of any `using` statements)
Where possible automatic [coercion](#coercion) will occur for all fields.

**Action Calling**
Calling actions in a generic way is not possible in Apama 10.1, so only a handful of particularly useful actions are supported. This will improve in 10.2.

|Action          |Description                                                   |
|---------------:|--------------------------------------------------------------|
|   `.toString()`|Call on any type to convert it to a string (has no effect on strings)|
|    `.toFloat()`|Call on any numeric type to convert to float                  |
|  `.toDecimal()`|Call on any numeric type to convert to decimal                |
|      `.round()`|Call on any numeric type to round to an integer               |
|       `.ceil()`|Call on any numeric type to round upwards to an integer       |
|      `.floor()`|Call on any numeric type to round downwards to an integer     |
|        `.abs()`|Call on any numeric type to provide the non-negative value    |
|       `.pow(n)`|Call on any numeric type to raise it to the `n`^th^ power     |
|       `.sqrt()`|Call on any numeric type to square root the value             |
|`.getTypeName()`|Call on any type to get its type name as a string             |

**Sequence Literals**
Sequences can be constructed in lambdas in much the same way that they can in EPL, except that they are always `sequence<any>`.
```javascript
Lambda.function1("x => [x, x + 1, x + 2]")(0) = [<any>0, 1, 2]
```
**Spread Operator**
The spread operator expands a sequence inside another sequence:
```javascript
Lambda.function1("x => [...x, 3, 4, 5]")([0, 1, 2]) = [<any>0, 1, 2, 3, 4, 5]
```
**Array Destructuring**
When using lambdas (particularly with Observables) you may find that a lambda is provided with a sequence as the argument. Rather than accessing each value using `seq[index]` it is easier to assign a name to each item in the sequence:
```javascript
Lambda.function1("[sum, count] => sum / count")([56, 7]) = <any> 8.0
```
<a id="coercion"></a>**Type Coercion**
Numbers and sometimes values are coerced to sensible types, using the following rules:
* Operations on two values of the same type _mostly_ result in the same type
* Operations on `integers` which may result in fractions result in `floats`
* Operations involving `integer` and `decimal` result in `decimal`
* Operations involving `integer` and `float` result in `float`
* Operations involving `float` and `decimal` result in `float`
* Operations on any type and `string` will call `.valueToString` on the any type

If you need the result to be a particular type (and that isn't possible through explicit typing eg. `22.0d`) then use the `.toFloat()`, `.toDecimal()`, `.round()`, `ceil()`, `.floor()`, `.toString()` actions.

------------------------------

These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
