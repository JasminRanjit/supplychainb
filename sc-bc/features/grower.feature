Feature: Tests related to Growers
    Background:
        Given I have deployed the business network definition ..
        And I have added the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":0},
        {"$class":"org.am.network.Shipper", "email":"shipper@email.com", "address":{"$class":"org.am.network.Address", "country":"Paname"}, "accountBalance":0}
        ]
        """
        And I have issued the participant org.am.network.Grower#grower@email.com with the identity grower1
        And I have issued the participant org.am.network.Shipper#shipper@email.com with the identity shipper1
        And I have added the following asset of type org.am.network.Contract
            | contractId | grower           | shipper               | importer              | arrivalDateTime  | unitPrice | minTemperature | maxTemperature | minPenaltyFactor | maxPenaltyFactor |
            | CON_001    | grower@email.com | shipper@email.com     | supermarket@email.com | 10/26/2018 00:00 | 0.5       | 2              | 10             | 0.2              | 0.1              | 
        And I have added the following asset of type org.am.network.Shipment
            | shipmentId | type    | status     | unitCount | contract |
            | SHIP_001   | BANANAS | IN_TRANSIT | 5000      | CON_001  |
        When I use the identity grower1

    Scenario: grower1 can read Grower assets
        Then I should have the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":0}
        ]
        """
    
    Scenario: grower1 invokes the ShipmentPacked transaction
        And I submit the following transaction of type org.am.network.ShipmentPacked
            | shipment |
            | SHIP_001 |
        Then I should have received the following event of type org.am.network.ShipmentPackedEvent
            | message                               | shipment |
            | Shipment packed for shipment SHIP_001 | SHIP_001 |

    Scenario: shipper1 cannot read Grower assets
        When I use the identity shipper1
        And I should have the following participants
        """
        [
        {"$class":"org.am.network.Grower", "email":"grower@email.com", "address":{"$class":"org.am.network.Address", "country":"USA"}, "accountBalance":0}
        ]
        """
        Then I should get an error matching /Object with ID .* does not exist/
    
    Scenario: shipper1 cannot invoke the ShipmentPacked transaction
        When I use the identity shipper1
        And I submit the following transaction of type org.am.network.ShipmentPacked
            | shipment |
            | SHIP_001 |
        Then I should get an error matching /Participant .* does not have 'CREATE' access to resource/
