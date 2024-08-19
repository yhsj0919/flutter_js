async function test() {
    var value = Math.trunc(Math.random() * 100).toString();
    var asyncResult = await sendMessage("getDataAsync", JSON.stringify({"count": Math.trunc(Math.random() * 10)}));

    alert(asyncResult)
    var err;
    try {
        await sendMessage("asyncWithError", "{}");
    } catch (e) {
        err = e.message || e;
    }
    return {"expression": value, "asyncResult": asyncResult, "expectedError": err};

}


async function test2() {
    try {
        const result = await test();
        console.log(result);
    } catch (error) {
        console.error("An error occurred:", error);
    }

    return "我是来自js的消息"

}

'success'
