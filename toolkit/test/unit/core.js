(function(){
  module("core");

  var iframe = document.createElement('iframe');
  jQuery(iframe).appendTo(document.body);
  var iDoc = iframe.contentDocument || iframe.contentWindow.document;
  iDoc.write(
    "<script>\
      parent.iElement   = document.createElement('div');\
      parent.iArguments = (function(){ return arguments; })(1, 2, 3);\
      parent.iArray     = [1, 2, 3];\
      parent.iString    = new String('hello');\
      parent.iNumber    = new Number(100);\
      parent.iFunction  = (function(){});\
      parent.iDate      = new Date();\
      parent.iRegExp    = /hi/;\
      parent.iNaN       = NaN;\
      parent.iNull      = null;\
      parent.iBoolean   = new Boolean(false);\
      parent.iUndefined = undefined;\
    </script>"
  );
  iDoc.close();

  test("G.extend(Object, Object)", function() {
    expect(28);

    var settings = { xnumber1: 5, xnumber2: 7, xstring1: "peter", xstring2: "pan" },
      options = { xnumber2: 1, xstring2: "x", xxx: "newstring" },
      optionsCopy = { xnumber2: 1, xstring2: "x", xxx: "newstring" },
      merged = { xnumber1: 5, xnumber2: 1, xstring1: "peter", xstring2: "x", xxx: "newstring" },
      deep1 = { foo: { bar: true } },
      deep1copy = { foo: { bar: true } },
      deep2 = { foo: { baz: true }, foo2: document },
      deep2copy = { foo: { baz: true }, foo2: document },
      deepmerged = { foo: { bar: true, baz: true }, foo2: document },
      arr = [1, 2, 3],
      nestedarray = { arr: arr };

    G.extend(settings, options);
    deepEqual( settings, merged, "Check if extended: settings must be extended" );
    deepEqual( options, optionsCopy, "Check if not modified: options must not be modified" );

    G.extend(settings, null, options);
    deepEqual( settings, merged, "Check if extended: settings must be extended" );
    deepEqual( options, optionsCopy, "Check if not modified: options must not be modified" );

    G.extend(true, deep1, deep2);
    deepEqual( deep1.foo, deepmerged.foo, "Check if foo: settings must be extended" );
    deepEqual( deep2.foo, deep2copy.foo, "Check if not deep2: options must not be modified" );
    equal( deep1.foo2, document, "Make sure that a deep clone was not attempted on the document" );

    ok( G.extend(true, {}, nestedarray).arr !== arr, "Deep extend of object must clone child array" );

    // #5991
    ok( G.isArray( G.extend(true, { arr: {} }, nestedarray).arr ), "Cloned array heve to be an Array" );
    ok( G.isPlainObject( G.extend(true, { arr: arr }, { arr: {} }).arr ), "Cloned object heve to be an plain object" );

    var empty = {};
    var optionsWithLength = { foo: { length: -1 } };
    G.extend(true, empty, optionsWithLength);
    deepEqual( empty.foo, optionsWithLength.foo, "The length property must copy correctly" );

    empty = {};
    var optionsWithDate = { foo: { date: new Date } };
    G.extend(true, empty, optionsWithDate);
    deepEqual( empty.foo, optionsWithDate.foo, "Dates copy correctly" );

    var myKlass = function() {};
    var customObject = new myKlass();
    var optionsWithCustomObject = { foo: { date: customObject } };
    empty = {};
    G.extend(true, empty, optionsWithCustomObject);
    ok( empty.foo && empty.foo.date === customObject, "Custom objects copy correctly (no methods)" );

    // Makes the class a little more realistic
    myKlass.prototype = { someMethod: function(){} };
    empty = {};
    G.extend(true, empty, optionsWithCustomObject);
    ok( empty.foo && empty.foo.date === customObject, "Custom objects copy correctly" );

    var ret = G.extend(true, { foo: 4 }, { foo: new Number(5) } );
    ok( ret.foo == 5, "Wrapped numbers copy correctly" );

    var nullUndef;
    nullUndef = G.extend({}, options, { xnumber2: null });
    ok( nullUndef.xnumber2 === null, "Check to make sure null values are copied");

    nullUndef = G.extend({}, options, { xnumber2: undefined });
    ok( nullUndef.xnumber2 === options.xnumber2, "Check to make sure undefined values are not copied");

    nullUndef = G.extend({}, options, { xnumber0: null });
    ok( nullUndef.xnumber0 === null, "Check to make sure null values are inserted");

    var target = {};
    var recursive = { foo:target, bar:5 };
    G.extend(true, target, recursive);
    deepEqual( target, { bar:5 }, "Check to make sure a recursive obj doesn't go never-ending loop by not copying it over" );

    var ret = G.extend(true, { foo: [] }, { foo: [0] } ); // 1907
    equal( ret.foo.length, 1, "Check to make sure a value with coersion 'false' copies over when necessary to fix #1907" );

    var ret = G.extend(true, { foo: "1,2,3" }, { foo: [1, 2, 3] } );
    ok( typeof ret.foo != "string", "Check to make sure values equal with coersion (but not actually equal) overwrite correctly" );

    var ret = G.extend(true, { foo:"bar" }, { foo:null } );
    ok( typeof ret.foo !== "undefined", "Make sure a null value doesn't crash with deep extend, for #1908" );

    var obj = { foo:null };
    G.extend(true, obj, { foo:"notnull" } );
    equal( obj.foo, "notnull", "Make sure a null value can be overwritten" );

    function func() {}
    G.extend(func, { key: "value" } );
    equal( func.key, "value", "Verify a function can be extended" );

    var defaults = { xnumber1: 5, xnumber2: 7, xstring1: "peter", xstring2: "pan" },
      defaultsCopy = { xnumber1: 5, xnumber2: 7, xstring1: "peter", xstring2: "pan" },
      options1 = { xnumber2: 1, xstring2: "x" },
      options1Copy = { xnumber2: 1, xstring2: "x" },
      options2 = { xstring2: "xx", xxx: "newstringx" },
      options2Copy = { xstring2: "xx", xxx: "newstringx" },
      merged2 = { xnumber1: 5, xnumber2: 1, xstring1: "peter", xstring2: "xx", xxx: "newstringx" };

    var settings = G.extend({}, defaults, options1, options2);
    deepEqual( settings, merged2, "Check if extended: settings must be extended" );
    deepEqual( defaults, defaultsCopy, "Check if not modified: options1 must not be modified" );
    deepEqual( options1, options1Copy, "Check if not modified: options1 must not be modified" );
    deepEqual( options2, options2Copy, "Check if not modified: options2 must not be modified" );
  });

  test("G.isPlainObject", function() {
    expect(15);

    stop();

    // The use case that we want to match
    ok(G.isPlainObject({}), "{}");

    // Not objects shouldn't be matched
    ok(!G.isPlainObject(""), "string");
    ok(!G.isPlainObject(0) && !G.isPlainObject(1), "number");
    ok(!G.isPlainObject(true) && !G.isPlainObject(false), "boolean");
    ok(!G.isPlainObject(null), "null");
    ok(!G.isPlainObject(undefined), "undefined");

    // Arrays shouldn't be matched
    ok(!G.isPlainObject([]), "array");

    // Instantiated objects shouldn't be matched
    ok(!G.isPlainObject(new Date), "new Date");

    var fn = function(){};

    // Functions shouldn't be matched
    ok(!G.isPlainObject(fn), "fn");

    // Again, instantiated objects shouldn't be matched
    ok(!G.isPlainObject(new fn), "new fn (no methods)");

    // Makes the function a little more realistic
    // (and harder to detect, incidentally)
    fn.prototype = {someMethod: function(){}};

    // Again, instantiated objects shouldn't be matched
    ok(!G.isPlainObject(new fn), "new fn");

    // DOM Element
    ok(!G.isPlainObject(document.createElement("div")), "DOM Element");

    // Window
    ok(!G.isPlainObject(window), "window");

    try {
      G.isPlainObject( window.location );
      ok( true, "Does not throw exceptions on host objects");
    } catch ( e ) {
      ok( false, "Does not throw exceptions on host objects -- FAIL");
    }

    try {
      var iframe = document.createElement("iframe");
      document.body.appendChild(iframe);

      window.iframeDone = function(otherObject){
        // Objects from other windows should be matched
        ok(G.isPlainObject(new otherObject), "new otherObject");
        document.body.removeChild( iframe );
        start();
      };

      var doc = iframe.contentDocument || iframe.contentWindow.document;
      doc.open();
      doc.write("<body onload='window.parent.iframeDone(Object);'>");
      doc.close();
    } catch(e) {
      document.body.removeChild( iframe );

      ok(true, "new otherObject - iframes not supported");
      start();
    }
  });

  test("G.isFunction", function() {
    expect(19);

    // Make sure that false values return false
    ok( !G.isFunction(), "No Value" );
    ok( !G.isFunction( null ), "null Value" );
    ok( !G.isFunction( undefined ), "undefined Value" );
    ok( !G.isFunction( "" ), "Empty String Value" );
    ok( !G.isFunction( 0 ), "0 Value" );

    // Check built-ins
    // Safari uses "(Internal Function)"
    ok( G.isFunction(String), "String Function("+String+")" );
    ok( G.isFunction(Array), "Array Function("+Array+")" );
    ok( G.isFunction(Object), "Object Function("+Object+")" );
    ok( G.isFunction(Function), "Function Function("+Function+")" );

    // When stringified, this could be misinterpreted
    var mystr = "function";
    ok( !G.isFunction(mystr), "Function String" );

    // When stringified, this could be misinterpreted
    var myarr = [ "function" ];
    ok( !G.isFunction(myarr), "Function Array" );

    // When stringified, this could be misinterpreted
    var myfunction = { "function": "test" };
    ok( !G.isFunction(myfunction), "Function Object" );

    // Make sure normal functions still work
    var fn = function(){};
    ok( G.isFunction(fn), "Normal Function" );

    var obj = document.createElement("object");

    // Firefox says this is a function
    ok( !G.isFunction(obj), "Object Element" );

    // IE says this is an object
    // Since 1.3, this isn't supported (#2968)
    //ok( G.isFunction(obj.getAttribute), "getAttribute Function" );

    var nodes = document.body.childNodes;

    // Safari says this is a function
    ok( !G.isFunction(nodes), "childNodes Property" );

    var first = document.body.firstChild;

    // Normal elements are reported ok everywhere
    ok( !G.isFunction(first), "A normal DOM Element" );

    var input = document.createElement("input");
    input.type = "text";
    document.body.appendChild( input );

    // IE says this is an object
    // Since 1.3, this isn't supported (#2968)
    //ok( G.isFunction(input.focus), "A default function property" );

    document.body.removeChild( input );

    var a = document.createElement("a");
    a.href = "some-function";
    document.body.appendChild( a );

    // This serializes with the word 'function' in it
    ok( !G.isFunction(a), "Anchor Element" );

    document.body.removeChild( a );

    // Recursive function calls have lengths and array-like properties
    function callme(callback){
      function fn(response){
        callback(response);
      }

      ok( G.isFunction(fn), "Recursive Function Call" );

      fn({ some: "data" });
    };

    callme(function(){
      callme(function(){});
    });
  });

  test("G.isWindow", function() {
    expect( 14 );

    ok( G.isWindow(window), "window" );
    ok( G.isWindow(document.getElementsByTagName("iframe")[0].contentWindow), "iframe.contentWindow" );
    ok( !G.isWindow(), "empty" );
    ok( !G.isWindow(null), "null" );
    ok( !G.isWindow(undefined), "undefined" );
    ok( !G.isWindow(document), "document" );
    ok( !G.isWindow(document.documentElement), "documentElement" );
    ok( !G.isWindow(""), "string" );
    ok( !G.isWindow(1), "number" );
    ok( !G.isWindow(true), "boolean" );
    ok( !G.isWindow({}), "object" );
    ok( !G.isWindow({ setInterval: function(){} }), "fake window" );
    ok( !G.isWindow(/window/), "regexp" );
    ok( !G.isWindow(function(){}), "function" );
  });

  test("G.isElement", function() {
    ok(!G.isElement('div'), 'strings are not dom elements');
    ok(G.isElement($('html')[0]), 'the html tag is a DOM element');
    ok(G.isElement(iElement), 'even from another frame');
  });

  test("G.isArguments", function() {
    var args = (function(){ return arguments; })(1, 2, 3);
    ok(!G.isArguments('string'), 'a string is not an arguments object');
    ok(!G.isArguments(G.isArguments), 'a function is not an arguments object');
    ok(G.isArguments(args), 'but the arguments object is an arguments object');
    ok(!G.isArguments(G.toArray(args)), 'but not when it\'s converted into an array');
    ok(!G.isArguments([1,2,3]), 'and not vanilla arrays.');
    ok(G.isArguments(iArguments), 'even from another frame');
  });

  test("G.isObject", function() {
    ok(G.isObject(arguments), 'the arguments object is object');
    ok(G.isObject([1, 2, 3]), 'and arrays');
    ok(G.isObject($('html')[0]), 'and DOM element');
    ok(G.isObject(iElement), 'even from another frame');
    ok(G.isObject(function () {}), 'and functions');
    ok(G.isObject(iFunction), 'even from another frame');
    ok(!G.isObject(null), 'but not null');
    ok(!G.isObject(undefined), 'and not undefined');
    ok(!G.isObject('string'), 'and not string');
    ok(!G.isObject(12), 'and not number');
    ok(!G.isObject(true), 'and not boolean');
    ok(G.isObject(new String('string')), 'but new String()');
  });

  test("G.isArray", function() {
    ok(!G.isArray(arguments), 'the arguments object is not an array');
    ok(G.isArray([1, 2, 3]), 'but arrays are');
    ok(G.isArray(iArray), 'even from another frame');
  });

  test("G.isString", function() {
    ok(!G.isString(document.body), 'the document body is not a string');
    ok(G.isString([1, 2, 3].join(', ')), 'but strings are');
    ok(G.isString(iString), 'even from another frame');
  });

  test("G.isNumber", function() {
    ok(!G.isNumber('string'), 'a string is not a number');
    ok(!G.isNumber(arguments), 'the arguments object is not a number');
    ok(!G.isNumber(undefined), 'undefined is not a number');
    ok(G.isNumber(3 * 4 - 7 / 10), 'but numbers are');
    ok(G.isNumber(NaN), 'NaN *is* a number');
    ok(G.isNumber(Infinity), 'Infinity is a number');
    ok(G.isNumber(iNumber), 'even from another frame');
    ok(!G.isNumber('1'), 'numeric strings are not numbers');
  });

  test("G.isBoolean", function() {
    ok(!G.isBoolean(2), 'a number is not a boolean');
    ok(!G.isBoolean("string"), 'a string is not a boolean');
    ok(!G.isBoolean("false"), 'the string "false" is not a boolean');
    ok(!G.isBoolean("true"), 'the string "true" is not a boolean');
    ok(!G.isBoolean(arguments), 'the arguments object is not a boolean');
    ok(!G.isBoolean(undefined), 'undefined is not a boolean');
    ok(!G.isBoolean(NaN), 'NaN is not a boolean');
    ok(!G.isBoolean(null), 'null is not a boolean');
    ok(G.isBoolean(true), 'but true is');
    ok(G.isBoolean(false), 'and so is false');
    ok(G.isBoolean(iBoolean), 'even from another frame');
  });

  test("G.isFunction", function() {
    ok(!G.isFunction([1, 2, 3]), 'arrays are not functions');
    ok(!G.isFunction('moe'), 'strings are not functions');
    ok(G.isFunction(G.isFunction), 'but functions are');
    ok(G.isFunction(iFunction), 'even from another frame');
  });

  test("G.isDate", function() {
    ok(!G.isDate(100), 'numbers are not dates');
    ok(!G.isDate({}), 'objects are not dates');
    ok(G.isDate(new Date()), 'but dates are');
    ok(G.isDate(iDate), 'even from another frame');
  });

  test("G.isRegExp", function() {
    ok(!G.isRegExp(G.identity), 'functions are not RegExps');
    ok(G.isRegExp(/identity/), 'but RegExps are');
    ok(G.isRegExp(iRegExp), 'even from another frame');
  });

  test("G.isFinite", function() {
    ok(!G.isFinite(undefined), 'undefined is not Finite');
    ok(!G.isFinite(null), 'null is not Finite');
    ok(!G.isFinite(NaN), 'NaN is not Finite');
    ok(!G.isFinite(Infinity), 'Infinity is not Finite');
    ok(!G.isFinite(-Infinity), '-Infinity is not Finite');
    ok(!G.isFinite('12'), 'Strings are not numbers');
    var obj = new Number(5);
    ok(G.isFinite(obj), 'Number instances can be finite');
    ok(G.isFinite(0), '0 is Finite');
    ok(G.isFinite(123), 'Ints are Finite');
    ok(G.isFinite(-12.44), 'Floats are Finite');
  });

  test("G.isNaN", function() {
    ok(!G.isNaN(undefined), 'undefined is not NaN');
    ok(!G.isNaN(null), 'null is not NaN');
    ok(!G.isNaN(0), '0 is not NaN');
    ok(G.isNaN(NaN), 'but NaN is');
    ok(G.isNaN(iNaN), 'even from another frame');
  });

  test("G.isNull", function() {
    ok(!G.isNull(undefined), 'undefined is not null');
    ok(!G.isNull(NaN), 'NaN is not null');
    ok(G.isNull(null), 'but null is');
    ok(G.isNull(iNull), 'even from another frame');
  });

  test("G.isUndefined", function() {
    ok(!G.isUndefined(1), 'numbers are defined');
    ok(!G.isUndefined(null), 'null is defined');
    ok(!G.isUndefined(false), 'false is defined');
    ok(!G.isUndefined(NaN), 'NaN is defined');
    ok(G.isUndefined(), 'nothing is undefined');
    ok(G.isUndefined(undefined), 'undefined is undefined');
    ok(G.isUndefined(iUndefined), 'even from another frame');
  });
})();
