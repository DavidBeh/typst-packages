// @region start:bug start:fix
Console.Write("Hello")
// @region end:bug end:fix
/*
// @region start:bug
Console.Write("World");
// prints "HelloWorld"
// @region end:bug
*/
// @region start:fix
Console.WriteLine(" World");
// calling "dotnet run test.cs" prints "Hello World\n"
// @region end:fix