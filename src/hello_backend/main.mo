import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Text "mo:base/Text";

actor WorkerAttendanceMarker {
  type Worker = {
    name : Text;
    role : Role;
    attendance : [Attendance]
  };

  type Supervisor = {
    name : Text;
    workers : [Worker];
  };

  type Attendance = {
    date : Text;
    status : Status;
  };

  type Status = {
    #Absent;
    #Present;
    #Left;
  };

  type Role = {
    #FrontendDeveloper;
    #BackendDeveloper;
    #BlockchainDeveloper;
  };

  // Creating DB for supervisors
  var supervisorDB = Buffer.Buffer<Supervisor>(0);

  // Register supervisor to supervisorDB
  public func registerSupervisor(supervisor:Supervisor): async Text{
    let _ = supervisorDB.add(supervisor);
    return "supervisor added";
  };

  // Query or get the number of supervisors in the database
  public query func getNumberOfSupervisors(): async Nat {
    return supervisorDB.size();
  };

  // Function to query all supervisors in DB
  public query func getAllSupervisors(): async [Supervisor] {
    let supervisors = Buffer.toArray(supervisorDB);
    return supervisors;
  };

  // Function to query supervisor by name
  public query func getSupervisorByName(name: Text): async ?Supervisor {
    let supervisors = Buffer.toArray(supervisorDB);
    for (supervisor in supervisors.vals()) {
      if (supervisor.name == name) {
        return ?supervisor;
      }
    };
    return null;
  };

  // Function to add a worker by a specific supervisor
  public func addWorkerToSupervisor(supervisorName: Text, worker: Worker): async Text {
    switch (await getSupervisorByName(supervisorName)) {
      case (?supervisor) {
        // Update the supervisor's list of workers
        let updatedWorkers = Array.append(supervisor.workers, [worker]);
        
        let supervisors = Buffer.toArray(supervisorDB);

        func match (s: Supervisor) : Supervisor {
          if (s.name == supervisorName) {
            return {
              name = s.name;
              workers = updatedWorkers;
            };
          } else {
            return s;
          }
        };
        // Update the supervisor in the database
        let updatedSupervisors = Array.map(supervisors, match);

        supervisorDB.clear();
        for (sup in updatedSupervisors.vals()) {
          let _ = supervisorDB.add(sup);
        };
        
        return "Worker added to supervisor";
      };
      case null {
        return "Supervisor not found";
      }
    }
  };

  // Function to query worker by name to show attendance
  public query func getWorkerByName(name: Text): async ?Worker {
    let supervisors = Buffer.toArray(supervisorDB);
    for (supervisor in supervisors.vals()) {
      for (worker in supervisor.workers.vals()) {
        if (worker.name == name) {
          return ?worker;
        }
      };
    };
    return null;
  };

  // Function to mark attendance for a worker by a specific supervisor by querying the student name then adding the attendance
  public func markAttendanceForWorker(supervisorName: Text, workerName: Text, attendance: Attendance): async Text {
    switch (await getSupervisorByName(supervisorName)) {
      case (?supervisor) {

        // Find and update the worker's attendance
        let updatedWorkers = Array.map<Worker, Worker>(supervisor.workers, func (w: Worker) : Worker {
            if (w.name == workerName) {
                let updatedAttendance = Array.append(w.attendance, [attendance]);
                return {
                    name = w.name;
                    role = w.role;
                    attendance = updatedAttendance;
                };
            } else {
                return w;
            }
        });

        let supervisors = Buffer.toArray(supervisorDB);

        // Update the supervisor in the database
        func match (s: Supervisor) : Supervisor {
            if (s.name == supervisorName) {
                return {
                    name = s.name;
                    workers = updatedWorkers;
                };
            } else {
                return s;
            }
        };

      let updatedSupervisors = Array.map<Supervisor, Supervisor>(supervisors, match);

      supervisorDB.clear();
      for (sup in updatedSupervisors.vals()) {
          let _ = supervisorDB.add(sup);
      };

        return "Attendance marked";
      };
      case null {
          return "Supervisor not found";
      }
    }
  };



};
