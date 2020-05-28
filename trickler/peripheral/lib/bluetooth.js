/**
  This code was copied from bleno to fix BT advertising:
  https://github.com/abandonware/bleno/blob/master/lib/hci-socket/gap.js#L28
 */
function makeAdData(name, serviceUuids) {
  var advertisementDataLength = 3;
  var scanDataLength = 0;

  var serviceUuids16bit = [];
  var serviceUuids128bit = [];
  var i = 0;

  if (name && name.length) {
    scanDataLength += 2 + name.length;
  }

  if (serviceUuids && serviceUuids.length) {
    for (i = 0; i < serviceUuids.length; i++) {
      var serviceUuid = Buffer.from(serviceUuids[i].match(/.{1,2}/g).reverse().join(''), 'hex');

      if (serviceUuid.length === 2) {
        serviceUuids16bit.push(serviceUuid);
      } else if (serviceUuid.length === 16) {
        serviceUuids128bit.push(serviceUuid);
      }
    }
  }

  if (serviceUuids16bit.length) {
    advertisementDataLength += 2 + 2 * serviceUuids16bit.length;
  }

  if (serviceUuids128bit.length) {
    advertisementDataLength += 2 + 16 * serviceUuids128bit.length;
  }

  var advertisementData = Buffer.alloc(advertisementDataLength);
  var scanData = Buffer.alloc(scanDataLength);

  // flags
  advertisementData.writeUInt8(2, 0);
  advertisementData.writeUInt8(0x01, 1);
  advertisementData.writeUInt8(0x06, 2);

  var advertisementDataOffset = 3;

  if (serviceUuids16bit.length) {
    advertisementData.writeUInt8(1 + 2 * serviceUuids16bit.length, advertisementDataOffset);
    advertisementDataOffset++;

    advertisementData.writeUInt8(0x03, advertisementDataOffset);
    advertisementDataOffset++;

    for (i = 0; i < serviceUuids16bit.length; i++) {
      serviceUuids16bit[i].copy(advertisementData, advertisementDataOffset);
      advertisementDataOffset += serviceUuids16bit[i].length;
    }
  }

  if (serviceUuids128bit.length) {
    advertisementData.writeUInt8(1 + 16 * serviceUuids128bit.length, advertisementDataOffset);
    advertisementDataOffset++;

    advertisementData.writeUInt8(0x06, advertisementDataOffset);
    advertisementDataOffset++;

    for (i = 0; i < serviceUuids128bit.length; i++) {
      serviceUuids128bit[i].copy(advertisementData, advertisementDataOffset);
      advertisementDataOffset += serviceUuids128bit[i].length;
    }
  }

  // name
  if (name && name.length) {
    var nameBuffer = Buffer.from(name);

    scanData.writeUInt8(1 + nameBuffer.length, 0);
    scanData.writeUInt8(0x08, 1);
    nameBuffer.copy(scanData, 2);
  }

  console.log('advertisementData:', advertisementData)
  console.log('advertisementDataLength:', advertisementDataLength)
  console.log('advertisementDataOffset:', advertisementDataOffset)
  console.log('nameBuffer:', nameBuffer)
  console.log('scanData:', scanData)
  console.log('serviceUuids16bit:', serviceUuids16bit)
  console.log('serviceUuids128bit:', serviceUuids128bit)

}

module.exports.makeAdData = makeAdData
