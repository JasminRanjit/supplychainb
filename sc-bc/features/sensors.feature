Feature: Tests related to IoT Devices

    Background:
        Given I have deployed the business network definition ..
        And I have added the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":0},
        {"$class":"org.am.network.Shipper", "email":"shipper@email.com", "address":{"$class":"org.am.network.Address", "country":"Panama"}, "accountBalance":0},
        {"$class":"org.am.network.Importer", "email":"importer@email.com", "address":{"$class":"org.am.network.Address", "country":"UK"}, "accountBalance":0}
        ]
        """
        And I have added the following participants of type org.am.network.TemperatureSensor
            | deviceId |
            | TEMP_001 |
        And I have added the following participant of type org.am.network.GpsSensor
            | deviceId |
            | GPS_001  |
        And I have issued the participant org.am.network.Grower#grower@email.com with the identity grower1
        And I have issued the participant org.am.network.Shipper#shipper@email.com with the identity shipper1
        And I have issued the participant org.am.network.TemperatureSensor#TEMP_001 with the identity sensor_temp1
        And I have issued the participant org.am.network.GpsSensor#GPS_001 with the identity sensor_gps1
        And I have added the following asset of type org.am.network.Contract
            | contractId | grower           | shipper               | importer              | arrivalDateTime  | unitPrice | minTemperature | maxTemperature | minPenaltyFactor | maxPenaltyFactor |
            | CON_001    | grower@email.com | shipper@email.com     | supermarket@email.com | 10/26/2018 00:00 | 0.5       | 2              | 10             | 0.2              | 0.1              | 
        And I have added the following asset of type org.am.network.Shipment
            | shipmentId | type    | status     | unitCount | contract |
            | SHIP_001   | BANANAS | IN_TRANSIT | 5000      | CON_001  |

    Scenario: Test TemperatureThresholdEvent is emitted when the max temperature threshold is violated
        When I use the identity sensor_temp1
        When I submit the following transactions of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |
        
        Then I should have received the following event of type org.am.network.TemperatureThresholdEvent
            | message                                                                          | temperature | shipment |
            | Temperature threshold violated! Emitting TemperatureEvent for shipment: SHIP_001 | 11          | SHIP_001 |    

    Scenario: Test TemperatureThresholdEvent is emitted when the min temperature threshold is violated
        When I use the identity sensor_temp1
        When I submit the following transactions of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 0          |
        
        Then I should have received the following event of type org.am.network.TemperatureThresholdEvent
            | message                                                                          | temperature | shipment |
            | Temperature threshold violated! Emitting TemperatureEvent for shipment: SHIP_001 | 0           | SHIP_001 |
    
    Scenario: Test ShipmentInPortEvent is emitted when GpsReading indicates arrival at destination port
        When I use the identity sensor_gps1
        When I submit the following transaction of type org.am.network.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |

        Then I should have received the following event of type org.am.network.ShipmentInPortEvent
            | message                                                                  | shipment |
            | Shipment has reached the destination port of /LAT:40.6840N/LONG:74.0062W | SHIP_001 |

    Scenario: GpsSensor sensor_gps1 can invoke GpsReading transaction
        When I use the identity sensor_gps1
        When I submit the following transaction of type org.am.network.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |
        Then I should have received the following event of type org.am.network.ShipmentInPortEvent
            | message                                                                  | shipment |
            | Shipment has reached the destination port of /LAT:40.6840N/LONG:74.0062W | SHIP_001 |
    
    Scenario: Temperature Sensor cannot invoke GpsReading transaction
        When I use the identity sensor_temp1
        When I submit the following transaction of type org.am.network.GpsReading
            | shipment | readingTime | readingDate | latitude | latitudeDir | longitude | longitudeDir |
            | SHIP_001 | 120000      | 20171025    | 40.6840  | N           | 74.0062   | W            |
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/

    Scenario: Gps Sensor cannot invoke TemperatureReading transaction
        When I use the identity sensor_gps1
        When I submit the following transactions of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |        
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/

    Scenario: Grower cannot invoke TemperatureReading transaction
        When I use the identity sensor_gps1
        When I submit the following transactions of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 11         |        
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/

