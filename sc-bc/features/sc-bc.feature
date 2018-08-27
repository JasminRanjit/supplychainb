Feature: Basic Test Scenarios

    Background:
        Given I have deployed the business network definition ..
        And I have added the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":0},
        {"$class":"org.am.network.Importer", "email":"supermarket@email.com", "address":{"$class":"org.am.network.Address", "country":"UK"}, "accountBalance":0}
        ]
        """
        And I have added the following participants of type org.am.network.TemperatureSensor
            | deviceId |
            | TEMP_001 |

        And I have issued the participant org.am.network.Grower#grower@email.com with the identity grower1
        And I have issued the participant org.am.network.Importer#supermarket@email.com with the identity importer1
        And I have issued the participant org.am.network.TemperatureSensor#TEMP_001 with the identity sensor_temp1
        
        And I have added the following asset of type org.am.network.Contract
            | contractId | grower           | shipper               | importer           | arrivalDateTime  | unitPrice | minTemperature | maxTemperature | minPenaltyFactor | maxPenaltyFactor |
            | CON_001    | grower@email.com | supermarket@email.com | supermarket@email.com | 10/26/2018 00:00 | 0.5       | 2              | 10             | 0.2              | 0.1              | 
        
        And I have added the following asset of type org.am.network.Shipment
            | shipmentId | type    | status     | unitCount | contract |
            | SHIP_001   | BANANAS | IN_TRANSIT | 5000      | CON_001  |

        And I submit the following transactions of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 4          |
            | SHIP_001 | 5          |
            | SHIP_001 | 10         |

        When I use the identity importer1

    Scenario: When the temperature range is within the agreed-upon boundaries
        And I submit the following transaction of type org.am.network.ShipmentReceived
            | shipment |
            | SHIP_001 |
        
        Then I should have the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":2500},
        {"$class":"org.am.network.Importer", "email":"supermarket@email.com", "address":{"$class":"org.am.network.Address", "country":"UK"}, "accountBalance":-2500}
        ]
        """
    
    Scenario: When the low/min temperature threshold is breached by 2 degrees C
        When I use the identity sensor_temp1
        And I submit the following transaction of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 0          |
        Then I use the identity importer1
        And I submit the following transaction of type org.am.network.ShipmentReceived
            | shipment |
            | SHIP_001 |
        Then I should have the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":500},
        {"$class":"org.am.network.Importer", "email":"supermarket@email.com", "address":{"$class":"org.am.network.Address", "country":"UK"}, "accountBalance":-500}
        ]
        """
    
    Scenario: When the hi/max temperature threshold is breached by 2 degrees C
        When I use the identity sensor_temp1
        And I submit the following transaction of type org.am.network.TemperatureReading
            | shipment | centigrade |
            | SHIP_001 | 12          |
        Then I use the identity importer1
        When I submit the following transaction of type org.am.network.ShipmentReceived
            | shipment |
            | SHIP_001 |
        Then I should have the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":1500},
        {"$class":"org.am.network.Importer", "email":"supermarket@email.com", "address":{"$class":"org.am.network.Address", "country":"UK"}, "accountBalance":-1500}
        ]
        """
    
    Scenario: When shipment is received a ShipmentReceivedEvent should be broadcast
        When I submit the following transaction of type org.am.network.ShipmentReceived
            | shipment |
            | SHIP_001 |
        Then I should have received the following event of type org.am.network.ShipmentReceivedEvent
            | message                    | shipment |
            | Shipment SHIP_001 received | SHIP_001 |
