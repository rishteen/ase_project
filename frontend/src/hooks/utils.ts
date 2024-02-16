export async function postData(url: string = "", data: any = {}): Promise<any> {
    // Default options are marked with *
    const response = await fetch(url, {
      method: "POST", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": "webquality",
        "X-Parse-REST-API-Key": "alistrongmasterkeyraee",
        "X-Parse-Master-Key": "alistrongmasterkeyraee",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    return await response.json(); // parses JSON response into native JavaScript objects
  }
  
  export async function getData(url: string = "", data: any = {}): Promise<any> {
    // Default options are marked with *
    const response = await fetch(url, {
      method: "GET", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": "webquality",
        "X-Parse-REST-API-Key": "alistrongmasterkeyraee",
        "X-Parse-Master-Key": "alistrongmasterkeyraee",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    return await response.json(); // parses JSON response into native JavaScript objects
  }
  export async function deleteData(url: string = "", data: any = {}): Promise<any> {
    // Default options are marked with *
    const response = await fetch(url, {
      method: "DELETE", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": "webquality",
        "X-Parse-REST-API-Key": "alistrongmasterkeyraee",
        "X-Parse-Master-Key": "alistrongmasterkeyraee",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    return await response.json(); // parses JSON response into native JavaScript objects
  }
  export async function updateData(url: string = "", data: any = {}): Promise<any> {
    // Default options are marked with *
    const response = await fetch(url, {
      method: "PUT", // *GET, POST, PUT, DELETE, etc.
      headers: {
        "Content-Type": "application/json",
        "X-Parse-Application-Id": "webquality",
        "X-Parse-REST-API-Key": "alistrongmasterkeyraee",
        "X-Parse-Master-Key": "alistrongmasterkeyraee",
        // 'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    return await response.json(); // parses JSON response into native JavaScript objects
  }
  
  export const getRandom = <T>(array: T[]): T => {
    const random_index = Math.floor(Math.random() * array.length);
    return array[random_index];
  };
  
  export const genRandomNumber = (start: number, end: number): number => {
    let number = start;
    number += Math.floor(Math.random() * (end - start));
    return number;
  }
  
  export const baseUrl = "https://parse-server.liara.run/parse";
  