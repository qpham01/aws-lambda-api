pushd ExampleApi\src\ExampleApi
dotnet publish -c Release -o ../../build ExampleApi.csproj
popd
pushd ExampleApi\build
7z a -tzip -r ..\..\build.zip *
popd
move /y build.zip example