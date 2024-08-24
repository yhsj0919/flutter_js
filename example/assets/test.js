async function test() {
    var value = Math.trunc(Math.random() * 100).toString();
    var asyncResult = await getDataAsync(JSON.stringify({"count": Math.trunc(Math.random() * 10)}));


    var nativeResult = await dartMethod(JSON.stringify({"count": Math.trunc(Math.random() * 10)}));

    console.log("这是注册的方法" + nativeResult)


    alert(asyncResult)

    var err;
    try {
        await asyncWithError("{}");
    } catch (e) {
        err = e.message || e;
    }
    return {"expression": value, "asyncResult": asyncResult, "expectedError": err};

}


async function test2(a, b) {

    console.log(arguments)
    for (let argument of arguments) {
        console.log(typeof argument,argument)
    }

    try {
        const result = await test();
        console.log(result);
    } catch (error) {
        console.error("An error occurred:", error);
    }

    return "我是来自js的消息"

}

'success'
