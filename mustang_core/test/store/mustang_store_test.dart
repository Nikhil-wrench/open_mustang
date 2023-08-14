import 'dart:convert';
import 'dart:io';

import 'package:mustang_core/mustang_core.dart';
import 'package:test/test.dart';

import 'fixture/models/address.dart';
import 'fixture/models/customer.dart';
import 'fixture/models/vehicle.dart';

void main() {
  group('Test Mustang store without persistence', () {
    setUp(() async {
      await MustangStore.nuke();
    });

    test('default', () async {
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('add an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('add multiple objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('persist an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      // persist should be ignored as it is not enabled
      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('update an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.update(Customer(name: customer.name, age: 35));
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(35));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      MustangStore.delete<Address>();
      address = MustangStore.get<Address>();

      expect(customer.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete all objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      await MustangStore.nuke();
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete some objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      await MustangStore.deleteObjects(preserveModels: ['$Customer']);
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });
  });

  group('Test Mustang store with persistence', () {
    setUp(() async {
      await MustangStore.configPersistence('unit-test', Directory.current.path);
      await MustangStore.nuke();
    });

    test('default', () async {
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('add an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('add multiple objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      MustangStore.persistObject('$Address', jsonEncode(address.toJson()));
      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
          addressStr,
          equals(
              '{"country":"India","state":"Karnataka","street":"Indiranagar"}'));
      expect(vehicleStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('restore objects from the persistent store', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      MustangStore.persistObject('$Address', jsonEncode(address.toJson()));
      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
        addressStr,
        equals(
          '{"country":"India","state":"Karnataka","street":"Indiranagar"}',
        ),
      );
      expect(vehicleStr, equals(null));

      MustangStore.deleteFromStore<Customer>();
      MustangStore.deleteFromStore<Address>();

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();
      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');
      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
        addressStr,
        equals(
          '{"country":"India","state":"Karnataka","street":"Indiranagar"}',
        ),
      );
      expect(vehicleStr, equals(null));

      await MustangStore.restoreState(json2Type, ['$Customer', '$Address']);
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');
      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
        addressStr,
        equals(
          '{"country":"India","state":"Karnataka","street":"Indiranagar"}',
        ),
      );
      expect(vehicleStr, equals(null));
    });

    test('update an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));

      MustangStore.update(Customer(name: customer.name, age: 35));
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(35));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":35}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete an object', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      MustangStore.persistObject('$Address', jsonEncode(address.toJson()));
      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
          addressStr,
          equals(
              '{"country":"India","state":"Karnataka","street":"Indiranagar"}'));
      expect(vehicleStr, equals(null));

      await MustangStore.delete<Address>();
      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete all objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');
      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));

      await MustangStore.nuke();

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });

    test('delete some objects', () async {
      MustangStore.update(Customer(name: 'Test User', age: 30));
      MustangStore.update(Address(
        country: 'India',
        state: 'Karnataka',
        street: 'Indiranagar',
      ));
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address!.country, equals('India'));
      expect(address.state, equals('Karnataka'));
      expect(address.street, equals('Indiranagar'));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      MustangStore.persistObject('$Address', jsonEncode(address.toJson()));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(
          addressStr,
          equals(
              '{"country":"India","state":"Karnataka","street":"Indiranagar"}'));
      expect(vehicleStr, equals(null));

      await MustangStore.deleteObjects(preserveModels: ['$Customer']);

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
    });
  });

  group('Test Mustang cache', () {
    setUp(() async {
      await MustangStore.configPersistence('unit-test', Directory.current.path);
      await MustangStore.nuke();
      await MustangCache.deleteObjects('cache-test');
    });

    test('Save and retrieve object in cache', () async {
      Customer? customer = MustangStore.get<Customer>();
      Address? address = MustangStore.get<Address>();
      Vehicle? vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      String? customerStr = await MustangStore.getPersistedObject('$Customer');
      String? addressStr = await MustangStore.getPersistedObject('$Address');
      String? vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));

      MustangStore.update(Customer(name: 'Test User', age: 30));

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      MustangStore.persistObject('$Customer', jsonEncode(customer.toJson()));
      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
      expect(MustangCache.itemExists('cache-test'), equals(false));

      await MustangCache.addObject('cache-test', '$Customer', customerStr!);

      expect(MustangCache.itemExists('cache-test'), equals(true));

      await MustangStore.nuke();

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer, equals(null));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals(null));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
      expect(MustangCache.itemExists('cache-test'), equals(true));

      await MustangCache.restoreObjects('cache-test', json2Type);

      customer = MustangStore.get<Customer>();
      address = MustangStore.get<Address>();
      vehicle = MustangStore.get<Vehicle>();

      expect(customer!.name, equals('Test User'));
      expect(customer.age, equals(30));
      expect(address, equals(null));
      expect(vehicle, equals(null));

      customerStr = await MustangStore.getPersistedObject('$Customer');
      addressStr = await MustangStore.getPersistedObject('$Address');
      vehicleStr = await MustangStore.getPersistedObject('$Vehicle');

      expect(customerStr, equals('{"name":"Test User","age":30}'));
      expect(addressStr, equals(null));
      expect(vehicleStr, equals(null));
      expect(MustangCache.itemExists('cache-test'), equals(true));
    });
  });
}

void json2Type(void Function<T>(T t) update, String modelName, String jsonStr) {
  if (modelName == '$Customer') {
    Customer customer = Customer.fromJson(jsonDecode(jsonStr));
    update(customer);
    return;
  }
  if (modelName == '$Address') {
    Address address = Address.fromJson(jsonDecode(jsonStr));
    update(address);
    return;
  }
  if (modelName == '$Vehicle') {
    Vehicle vehicle = Vehicle.fromJson(jsonDecode(jsonStr));
    update(vehicle);
    return;
  }
}
