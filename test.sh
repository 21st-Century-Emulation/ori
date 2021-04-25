docker build -q -t ori .
docker run --rm --name ori -d -p 8080:8080 ori

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":246,"state":{"a":181,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute?operand1=15`
EXPECTED='{"id":"abcd", "opcode":246,"state":{"a":191,"b":1,"c":0,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":false,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":7,"interruptsEnabled":true}}'

docker kill ori

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mORI Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mORI Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi