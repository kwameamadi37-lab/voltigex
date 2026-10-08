<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB; 


class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        // Remove auth middleware since we're using API authentication
        // $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *  
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        // For now, return empty data since we're using API authentication
        // The frontend will handle data fetching via API calls
        $virements = collect([]);
        $historiques = collect([]);
        
        return view('home', compact('virements', 'historiques'));
    }
       
 
}    
