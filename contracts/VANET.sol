// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

//  Project Title: Secure Authentication and Trusted Data Recording
contract VanetSystem {

    // تعريف هيكل المركبة (للمصادقة)
    struct Vehicle {
        string licensePlate;
        string ownerName;
        bool isRegistered;
        uint256 reputationScore;
    }

    // تعريف هيكل الحدث (لتسجيل البيانات الموثوق)
    struct TrafficEvent {
        uint256 eventId;
        address reporter;
        string eventType; // e.g., "Accident", "Traffic Jam"
        string location;
        uint256 timestamp;
        string dataHash; // لتأكيد عدم تلاعب البيانات (Integrity)
    }

    address public trafficAuthority; // المسؤول (Admin)
    mapping(address => Vehicle) public vehicles; // سجل المركبات
    TrafficEvent[] public events; // سجل الحوادث (Data Recording)

    // الأحداث (Events) للمساعدة في التتبع والـ Forensics
    event VehicleRegistered(address indexed vehicleAddress, string licensePlate);
    event EventReported(uint256 indexed eventId, address indexed reporter, string eventType, uint256 timestamp);

    // [cite: 15] تحديد الصلاحيات (Permissions)
    modifier onlyAuthority() {
        require(msg.sender == trafficAuthority, "Only Traffic Authority can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(vehicles[msg.sender].isRegistered, "Vehicle is not authenticated");
        _;
    }

    constructor() {
        trafficAuthority = msg.sender; // أول من ينشر العقد هو المسؤول
    }

    // [cite: 14] دالة المصادقة وتسجيل المركبة
    function registerVehicle(address _vehicleAddress, string memory _licensePlate, string memory _ownerName) public onlyAuthority {
        require(!vehicles[_vehicleAddress].isRegistered, "Vehicle already registered");
        
        vehicles[_vehicleAddress] = Vehicle({
            licensePlate: _licensePlate,
            ownerName: _ownerName,
            isRegistered: true,
            reputationScore: 100
        });

        emit VehicleRegistered(_vehicleAddress, _licensePlate);
    }

    // [cite: 14] دالة تخزين البيانات الموثوقة (الإبلاغ عن حادث)
    function reportEvent(string memory _eventType, string memory _location, string memory _dataHash) public onlyRegistered {
        
        uint256 newEventId = events.length;
        
        events.push(TrafficEvent({
            eventId: newEventId,
            reporter: msg.sender,
            eventType: _eventType,
            location: _location,
            timestamp: block.timestamp,
            dataHash: _dataHash
        }));

        emit EventReported(newEventId, msg.sender, _eventType, block.timestamp);
    }

    // دالة مساعدة لجلب عدد الأحداث
    function getEventsCount() public view returns (uint256) {
        return events.length;
    }
}
