import React from "react";

const Footer: React.FC = () => {
  return (
    <footer className="bg-sky-600  text-white py-6 mt-10 rounded-t-[10px]">
      <div className="container mx-auto px-4 flex flex-col md:flex-row justify-between">
        <div>
          <h2 className="font-bold text-lg">VolunteerHere</h2>
          <p className="text-sm">Connecting volunteers with meaningful events. Here !</p>
        </div>

        <div className="flex space-x-6 mt-4 md:mt-0">
          <a href="/about">About Us</a>
          <a href="/events">Events</a>
          <a href="/register">Volunteer</a>
          <a href="/contact">Contact</a>
        </div>

        <div className="text-sm mt-4 md:mt-0">
          © {new Date().getFullYear()} VolunteerHere. All rights reserved.
        </div>
      </div>
    </footer>
  );
};

export default Footer;
