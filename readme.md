[![N|Solid](https://s3-us-west-2.amazonaws.com/pinc-backend/images/cdn/rvalidator.png)](https://williamsisaac.com)

# Request Validator


Request validator is a gem thats allows you do run validation in your controller rather than your models. Why do you need `validates :question, presence: true` in model when `v.check('param').notEmpty()` solves it

### Installation

No dependency! 

```sh
$ gem install request_validator
```

Configuration

```
Validator.configure do |config|
	config.skip_main_object_empty = true
	config.error_mode = 'surpressed'
end
```

### Config

Dillinger is currently extended with the following plugins. Instructions on how to use them in your own application are linked below.

| Option | Description |
| ------ | ------ |
| skip_main_object_empty | Allows your to skip error when the main object is empty. Default is `false` |
| error_mode | silences errors and move on to next step |



### Usage

This gem can be used in two ways and both returns same response in same format.

We will be using this params throughout
```
{
	"name": "User 1",
	"phone": "789",
	"role" : "admin",
	"email": "will@mail.com",
	"website": "https://google.com",
	"actions": ["jsjjd","skskjd"],
}
```

The first method allows you to match params to methods without explicitly specifying the methods.


```
Validator.new.validate(params, {
	'name' => 'string',
	'phone' => 'number',
	'email' => 'email',
})
```

If thers are any errors, response object containing property `error` as an array containing the error messages is returned


It skips other params if they are not specified...

### Method Chaining

Example

```
v = Validator.new(params)
v.check('email').notEmpty().isEmail()
v.check('name').isString().notEmpty()
v.check('role').isIn(['admin', 'user']).notEmpty()
v.check('actions').isArray()
v.check('website').validUrl()
v.result()
```

Using this method, it allows changing of methods together. The method `check` must be specified a parameter is passed into it which is the property to check for.

The `params` body must me passed into the new method of the validator. 

Example response

```
{
    "error": [
        "phone is not a valid number"
    ]
}
```


### Todos

 - Write tests (but its working right now)
 - Include more methods
 - More documentation

License
----

MIT


**Free Software, Hell Yeah!**
